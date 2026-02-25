#!/bin/bash
set -euo pipefail

# Co-Authored-By: Claude.ai
#
# Downloads the broadcom-wl Arch package matching a given kernel version.
# Needed for BCM4360 WiFi on Intel 2012 Macs (and similar) during archiso install.
#
# Usage: ./get-broadcom-wl.sh <kernel-version>
# Example: ./get-broadcom-wl.sh 6.18.7-arch1-1

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <kernel-version>" >&2
    echo "Example: $0 6.18.7-arch1-1" >&2
    exit 1
fi

if ! command -v curl &>/dev/null; then
    echo "Error: curl is required" >&2
    exit 1
fi

KERNEL_VER="$1"
# uname -r gives 6.18.7-arch1-1, Arch packages/commits use 6.18.7.arch1-1
PKG_KERNEL_VER="${KERNEL_VER/-/.}"
# Escape dots for use in regex
PKG_KERNEL_REGEX="${PKG_KERNEL_VER//./\\.}"

GITLAB_API="https://gitlab.archlinux.org/api/v4/projects/archlinux%2Fpackaging%2Fpackages%2Fbroadcom-wl/repository/commits"
ARCHIVE_BASE="https://archive.archlinux.org/packages/b/broadcom-wl"

echo "Searching for broadcom-wl matching kernel: $PKG_KERNEL_VER"

page=1
revision=""

while [[ -z "$revision" && $page -le 30 ]]; do
    response=$(curl -sf "${GITLAB_API}?per_page=100&page=${page}") || {
        echo "Error: GitLab API request failed" >&2
        exit 1
    }

    [[ "$response" == "[]" ]] && break

    revision=$(echo "$response" \
        | grep -o '"title":"6\.30\.223\.271-[0-9]*: linux '"${PKG_KERNEL_REGEX}"'"' \
        | sed 's/.*-\([0-9]*\):.*/\1/' \
        | head -1)

    ((page++))
done

if [[ -z "$revision" ]]; then
    echo "Error: no broadcom-wl package found for kernel $PKG_KERNEL_VER" >&2
    exit 1
fi

PKG="broadcom-wl-6.30.223.271-${revision}-x86_64.pkg.tar.zst"
URL="${ARCHIVE_BASE}/${PKG}"

echo "Found: revision $revision"
echo "Downloading: $URL"
curl -L --progress-bar -O "$URL"
echo "Done: $PKG"
