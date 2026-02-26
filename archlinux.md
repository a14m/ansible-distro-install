# Install ArchLinux

- Download [archlinux](https://archlinux.org/releng/releases/)
- Format a USB
- Unmount disk (on MacOS ex. `diskutil unmountDisk /dev/diskX`)
- Create bootable image from iso `sudo dd if=/path/to/image.iso of=/dev/diskX bs=4M status=progress`
- Boot the `archiso` live image from a bootable USB.
- Set root password (which will be asked to run the install playbook).

## Generic Machine

- Connect to wireless network (if not connected via LAN).
- `cp host_vars/archiso.local.example host_vars/archiso.local`
- Update the `host_vars/archiso.local` file
- Run the playbook on the ansible controller

**Example:**

```bash
hostnamectl set-hostname archiso.local
passwd
iwctl --passphrase <PASSPHRASE> station wlan0 connect <SSID>
dhcpcd wlan0
```

## MacBookPro 2012 (without WIFI)

- On another machine, download the matching broadcom-wl package (using `scripts/get-broadcom-wl.sh`)
- Copy broadcom-wl package to a FAT32 USB drive
- Remove conflicting kernel modules (`brcmfmac brcmutil b43 ssb bcma wl`)
- Load the `broadcom-wl` driver from USB
- Connect to wireless network
- `cp host_vars/mac-archiso.local.example host_vars/mac-archiso.local`
- Update the `host_vars/mac-archiso.local` file
- Run the playbook on the ansible controller

**Example:**

To download the correct `broadcom-wl` driver use the following:

```bash
# On the mac machine without the wifi driver
uname -r

# On a machine with working internet connection
scripts/get-broadcom-wl.sh <KERNEL>
cp broadcom-wl-6.30.223.271-<REV>-x86_64.pkg.tar.zst /mnt/sdX
```

```bash
# On the mac machine without the wifi driver
hostnamectl set-hostname mac-archiso.local
passwd

lsblk
mkdir -p /mnt/usb && mount /dev/sdX /mnt/usb
cd /tmp
bsdtar -xf /mnt/usb/broadcom-wl-6.30.223.271-<REV>-x86_64.pkg.tar.zst

# Fix loading the driver
rmmod brcmfmac brcmutil b43 ssb bcma wl
insmod usr/lib/modules/<KERNEL>/extramodules/wl.ko.zst
# rmmod bcma if needed because it was auto-reloaded

rfkill unblock all
ip link

iwctl --passphrase <PASSPHRASE> station wlan0 connect <SSID>
dhcpcd wlan0
```
