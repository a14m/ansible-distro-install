#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <distro> <kernel-version>"
  echo "  kernel-version: output of 'uname -r' on target machine"
  echo "  Example: $0 noble 6.11.0-17-generic"
  echo "  Example: $0 resolute 7.0.0-15-generic"
  exit 1
}

[[ $# -ne 2 ]] && usage

DISTRO="$1"
KERNEL_VERSION="$2"
OUTPUT_DIR="/tmp/bcmwl-drivers-${KERNEL_VERSION}"
BASE_URL="http://archive.ubuntu.com/ubuntu"
INDEX_DIR=$(mktemp -d)

cleanup() { rm -rf "$INDEX_DIR"; }

fetch_index() {
  local pocket="$1" component="$2"
  local dest="${INDEX_DIR}/${pocket}-${component}.txt"
  echo "Fetching ${pocket}/${component} index..." >&2
  if ! curl -fsSL "${BASE_URL}/dists/${pocket}/${component}/binary-amd64/Packages.gz" \
    | gzip -d > "$dest"; then
    echo "ERROR: failed to fetch ${BASE_URL}/dists/${pocket}/${component} (HTTP 404? wrong distro name?)" >&2
    exit 1
  fi
  echo "$dest"
}

pkg_field() {
  local index="$1" pkg_name="$2" field="$3"
  awk '/^Package: '"$pkg_name"'$/{found=1} found && /^'"$field"':/{print; found=0; exit}' "$index"
}

pkg_filename() {
  pkg_field "$1" "$2" "Filename" | awk '{print $2}'
}

download_pkg() {
  local pkg_name="$1"
  local filename=""
  for index in "${INDEXES[@]}"; do
    filename=$(pkg_filename "$index" "$pkg_name")
    [[ -n "$filename" ]] && break
  done
  if [[ -z "$filename" ]]; then
    echo "WARNING: $pkg_name not found in any index, skipping" >&2
    return 0
  fi
  local deb
  deb=$(basename "$filename")
  if [[ -f "${OUTPUT_DIR}/${deb}" ]]; then
    echo "  (cached) $deb"
    return 0
  fi
  echo "Downloading $deb..."
  curl -fL -o "${OUTPUT_DIR}/${deb}" "${BASE_URL}/${filename}"
}

require_pkg() {
  local pkg_name="$1"
  local filename=""
  for index in "${INDEXES[@]}"; do
    filename=$(pkg_filename "$index" "$pkg_name")
    [[ -n "$filename" ]] && break
  done
  if [[ -z "$filename" ]]; then
    echo "ERROR: required package $pkg_name not found in any index" >&2
    exit 1
  fi
  local deb
  deb=$(basename "$filename")
  if [[ -f "${OUTPUT_DIR}/${deb}" ]]; then
    echo "  (cached) $deb"
    return 0
  fi
  echo "Downloading $deb..."
  curl -fL -o "${OUTPUT_DIR}/${deb}" "${BASE_URL}/${filename}"
}

# Create out directory and configure trap signal
mkdir -p "$OUTPUT_DIR"
trap cleanup EXIT

# Fetch indexes
main_index=$(fetch_index "$DISTRO" "main")
restricted_index=$(fetch_index "$DISTRO" "restricted")
main_updates=$(fetch_index "${DISTRO}-updates" "main")
restricted_updates=$(fetch_index "${DISTRO}-updates" "restricted")
INDEXES=("$main_updates" "$restricted_updates" "$main_index" "$restricted_index")

# Auto-discover gcc version from distro's gcc metapackage
GCC_VER=$(pkg_field "$main_index" "gcc" "Depends" \
  | grep -o 'gcc-[0-9]*' | head -1 | cut -d- -f2 || true)
if [[ -z "$GCC_VER" ]]; then
  echo "ERROR: cannot determine gcc version from index" >&2
  exit 1
fi
echo "Detected gcc version: $GCC_VER"

# Kernel headers
require_pkg "linux-headers-${KERNEL_VERSION}"

# Auto-discover base headers from Depends: field (search all indexes)
BASE_HEADERS_PKG=""
for index in "${INDEXES[@]}"; do
  BASE_HEADERS_PKG=$(pkg_field "$index" "linux-headers-${KERNEL_VERSION}" "Depends" \
    | grep -o 'linux-headers-[0-9][^ ,)]*\|linux-hwe-[^ ,)]*' | head -1 || true)
  [[ -n "$BASE_HEADERS_PKG" ]] && break
done
if [[ -n "$BASE_HEADERS_PKG" ]]; then
  echo "Base headers: $BASE_HEADERS_PKG"
  download_pkg "$BASE_HEADERS_PKG"
fi

# Broadcom source
require_pkg "broadcom-sta-dkms"

# Build tools (not pre-installed on Ubuntu live ISO)
echo "Downloading build tools..."
for pkg in \
  make \
  gcc-${GCC_VER}-base \
  cpp-${GCC_VER}-x86-64-linux-gnu cpp-${GCC_VER} cpp-x86-64-linux-gnu cpp \
  gcc-${GCC_VER}-x86-64-linux-gnu gcc-${GCC_VER} gcc-x86-64-linux-gnu gcc \
  binutils-common libsframe1 libbinutils libctf-nobfd0 libctf0 \
  libjansson4 libgprofng0 binutils-x86-64-linux-gnu binutils \
  libcc1-0 libisl23 libmpfr6 libmpc3 libgcc-${GCC_VER}-dev lto-disabled-list; do
  download_pkg "$pkg"
done

# Copy install script alongside the debs
cp "$(dirname "$0")/install-wl.sh" "$OUTPUT_DIR/"
chmod +x "$OUTPUT_DIR/install-wl.sh"
echo ""
echo "Downloaded to $OUTPUT_DIR"
