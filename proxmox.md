# Install Proxmox

- Download [Debian Standard Live ISO](https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/)
- Format a USB
- Unmount disk (on MacOS ex. `diskutil unmountDisk /dev/diskX`)
- Create bootable image from iso `sudo dd if=/path/to/image.iso of=/dev/diskX bs=4M status=progress`
- Boot the `Debian Live ISO` live image from a bootable USB
- Connect to wireless network (if not connected via LAN)
- Set root password (which will be asked to run the install playbook)
- Set the host name `proxmox-iso.local`
- Install and configure ssh
- `cp host_vars/proxmox-iso.local.example host_vars/proxmox-iso.local`
- Update the `host_vars/proxmox-iso.local` file
- Run the playbook on the ansible controller

**Example:**

```bash
sudo hostnamectl set-hostname proxmox-iso
sudo passwd user
nmcli dev wifi connect <SSID> password <PASSPHRASE>
sudo apt update
sudo apt install -y openssh-server
sudo systemctl restart ssh avahi-daemon
```

**Mac Example:**

TBD
