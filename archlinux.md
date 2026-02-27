# Install ArchLinux

- Download [archlinux](https://archlinux.org/releng/releases/)
- Format a USB
- Unmount disk (on MacOS ex. `diskutil unmountDisk /dev/diskX`)
- Create bootable image from iso `sudo dd if=/path/to/image.iso of=/dev/diskX bs=4M status=progress`
- Boot the `archiso` live image from a bootable USB.
- Set root password (which will be asked to run the install playbook).
- Reload `boradcom-wl` module on Mac.
- Connect to wireless network (if not connected via LAN).
- `cp host_vars/archiso.local.example host_vars/archiso.local`
- Update the `host_vars/archiso.local` file.
- Run the playbook on the ansible controller.

**Generic Example:**

```bash
hostnamectl set-hostname archiso.local
passwd
iwctl --passphrase <PASSPHRASE> station wlan0 connect <SSID>
dhcpcd wlan0
```

**Mac Example:**

```bash
hostnamectl set-hostname mac-archiso.local
passwd
rmmod b43 ssb bcma wl
modprobe wl
ip link
iwctl --passphrase <PASSPHRASE> station wlan0 connect <SSID>
dhcpcd wlan0
```
