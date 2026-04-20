#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <kernel-version>"
  echo "  kernel-version: output of 'uname -r' on target machine"
  echo "  Example: $0 6.11.0-17-generic"
  exit 1
}

[[ $# -ne 1 ]] && usage

KERNEL_VERSION="$1"
OUTPUT_DIR="/tmp/bcmwl-drivers"
BASE_URL="http://archive.ubuntu.com/ubuntu"
DISTRO="noble"
INDEX_DIR=$(mktemp -d)

cleanup() { rm -rf "$INDEX_DIR"; }

fetch_index() {
  local pocket="$1" component="$2"
  local dest="${INDEX_DIR}/${pocket}-${component}.txt"
  echo "Fetching ${pocket}/${component} index..." >&2
  curl -fsSL "${BASE_URL}/dists/${pocket}/${component}/binary-amd64/Packages.gz" \
    | gzip -d > "$dest"
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

# Create out directory and configure trap signal
mkdir -p "$OUTPUT_DIR"
trap cleanup EXIT

# Fetch indexes
main_index=$(fetch_index "$DISTRO" "main")
main_updates=$(fetch_index "${DISTRO}-updates" "main")
restricted_updates=$(fetch_index "${DISTRO}-updates" "restricted")
INDEXES=("$main_updates" "$main_index" "$restricted_updates")

# Kernel headers
download_pkg "linux-headers-${KERNEL_VERSION}"

# Auto-discover base headers from Depends: field
BASE_HEADERS_PKG=$(pkg_field "$main_updates" "linux-headers-${KERNEL_VERSION}" "Depends" \
  | grep -o 'linux-hwe-[^ ,)]*' | head -1)
if [[ -n "$BASE_HEADERS_PKG" ]]; then
  echo "Base headers: $BASE_HEADERS_PKG"
  download_pkg "$BASE_HEADERS_PKG"
fi

# Broadcom source
download_pkg "broadcom-sta-dkms"

# Build tools (not pre-installed on Ubuntu live ISO)
echo "Downloading build tools..."
for pkg in \
  make \
  gcc-13-base \
  cpp-13-x86-64-linux-gnu cpp-13 cpp-x86-64-linux-gnu cpp \
  gcc-13-x86-64-linux-gnu gcc-13 gcc-x86-64-linux-gnu gcc \
  binutils-common libsframe1 libbinutils libctf-nobfd0 libctf0 \
  libjansson4 libgprofng0 binutils-x86-64-linux-gnu binutils \
  libcc1-0 libisl23 libmpfr6 libmpc3 libgcc-13-dev lto-disabled-list; do
  download_pkg "$pkg"
done

# Copy install script alongside the debs
cp "$(dirname "$0")/install-wl.sh" "$OUTPUT_DIR/"
chmod +x "$OUTPUT_DIR/install-wl.sh"
echo ""
echo "Downloaded to $OUTPUT_DIR:"
