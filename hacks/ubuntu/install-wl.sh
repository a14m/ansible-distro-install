#!/usr/bin/env bash
set -euo pipefail

# Builds and loads the Broadcom BCM4360 wl driver on a Ubuntu live ISO.
# Must be run with access to the debs downloaded by mac-drivers.sh.
# gcc/make/binutils are extracted from the downloaded debs — not assumed pre-installed.
#
# Usage: bash install-wl.sh <path-to-debs-dir>

usage() {
  echo "Usage: $0 <debs-dir>"
  echo "  debs-dir: directory containing broadcom-sta-dkms and linux-headers debs"
  exit 1
}

[[ $# -ne 1 ]] && usage

DEBS_DIR="$1"
KERNEL_VERSION="$(uname -r)"

if [[ ! -d "$DEBS_DIR" ]]; then
  echo "ERROR: $DEBS_DIR is not a directory" >&2
  exit 1
fi

echo "Extracting packages to / (overlayfs — changes are in RAM, lost on reboot)..."
for deb in "$DEBS_DIR"/*.deb; do
  echo "  $(basename "$deb")"
  sudo dpkg -x "$deb" /
done

SRC_DIR=$(find /usr/src -maxdepth 1 -name "broadcom-sta-*" -type d 2>/dev/null | head -1)
if [[ -z "$SRC_DIR" ]]; then
  echo "ERROR: broadcom-sta source not found in /usr/src/ after extraction" >&2
  exit 1
fi

if [[ ! -d "/lib/modules/$KERNEL_VERSION/build" ]]; then
  echo "ERROR: /lib/modules/$KERNEL_VERSION/build not found" >&2
  echo "  Expected linux-headers-$KERNEL_VERSION to be extracted" >&2
  exit 1
fi

echo "Building wl.ko for kernel $KERNEL_VERSION from $SRC_DIR..."
sudo KBUILD_NOPEDANTIC=1 make \
  -C "/lib/modules/$KERNEL_VERSION/build" \
  M="$SRC_DIR" \
  -j1

echo "Unloading conflicting modules..."
sudo rmmod wl 2>/dev/null || true
sudo rmmod b43 ssb bcma brcmfmac brcmutil 2>/dev/null || true

echo "Loading wl.ko..."
sudo insmod "$SRC_DIR/wl.ko"
sudo rfkill unblock all
echo "Done."
