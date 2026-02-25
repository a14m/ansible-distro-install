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
- Load the broadcom-wl driver from USB
- Connect to wireless network
- `cp host_vars/mac-archiso.local.example host_vars/mac-archiso.local`
- Update the `host_vars/mac-archiso.local` file
- Run the playbook on the ansible controller

**Example:**

```bash
hostnamectl set-hostname mac-archiso.local
passwd

# Get the running kernel version (used to find the right package and insmod path)
uname -r

# Identify USB partition
lsblk
# Copy driver to MacBookPro archiso
mkdir /mnt/usb
mount /dev/sdb /mnt/usb
cd /tmp
bsdtar -xf /mnt/usb/broadcom-wl-6.30.223.271-<REV>-x86_64.pkg.tar.zst

# Fix loading the driver
rmmod brcmfmac brcmutil b43 ssb bcma wl
# should be empty
lsmod | grep -E 'brcmfmac|brcmutil|b43|ssb|bcma|wl'
# Insert module
insmod usr/lib/modules/<KERNEL>/extramodules/wl.ko.zst
# bcma auto-reloads, remove it again
rmmod bcma

# should show wlan0
rfkill unblock all
ip link

# Connect to network
iwctl --passphrase <PASSPHRASE> station wlan0 connect <SSID>
dhcpcd wlan0
```
