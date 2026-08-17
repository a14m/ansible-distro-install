# Install ArchLinux

- Download [archlinux](https://archlinux.org/releng/releases/)
- Format a USB
- Unmount disk (on MacOS ex. `diskutil unmountDisk /dev/diskX`)
- Create bootable image from iso `sudo dd if=/path/to/image.iso of=/dev/diskX bs=4M status=progress`
- Boot the `archiso` live image from a bootable USB.
- Set root password (which will be asked to run the install playbook).
- Set the host name `arch-<MACHINE>-iso.local`
- Reload `boradcom-wl` module on Mac.
- Connect to wireless network (if not connected via LAN).
- `cp host_vars/arch-<MACHINE>-iso.local.example host_vars/arch-<MACHINE>-iso.local`
- Update the `host_vars/arch-<MACHINE>-iso.local` file
- Run the playbook on the ansible controller.

**Generic Example:**

```bash
hostnamectl set-hostname arch-<MACHINE>-iso.local
passwd
iwctl --passphrase <PASSPHRASE> station wlan0 connect <SSID>
dhcpcd wlan0
```

**Mac Example:**

```bash
hostnamectl set-hostname arch-macbook-iso.local
passwd
rmmod b43 ssb bcma wl
modprobe wl
ip link
iwctl --passphrase <PASSPHRASE> station wlan0 connect <SSID>
dhcpcd wlan0
```

Note: on `desktop.local`, the onboard QCA6174 wifi (`ath10k_pci`) has a confirmed hardware fault
it's blacklisted on the installed system via `bootstrap_blacklist_modules`.

Instead an old WIFI adapter is used instead, but because it can only work with the 2.4GHz band,
the download speed is limited, and to avoid extra instabilities, the IPv6 is disabled on the interface.

```bash
modprobe -r ath10k_pci
modprobe rtl8187
ip link
ethtool -i wlan0
sysctl -w net.ipv6.conf.wlan0.disable_ipv6=1
```
