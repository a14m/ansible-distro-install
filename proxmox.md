# Install Proxmox

- Download [Debian Standard Live ISO](https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/)
- Format a USB
- Unmount disk (on MacOS ex. `diskutil unmountDisk /dev/diskX`)
- Create bootable image from iso `sudo dd if=/path/to/image.iso of=/dev/diskX bs=4M status=progress`
- Boot the `Debian Live ISO` live image from a bootable USB
- Connect to wireless network (if not connected via LAN)
- Set root password (which will be asked to run the install playbook)
- Wipe FS and remove LVM signatures if any (to release the partitions for the playbook).
- Set the host name `proxmox-<MACHINE>-iso.local`
- Install and configure ssh
- `cp host_vars/proxmox-<MACHINE>-iso.local.yml.example host_vars/proxmox-<MACHINE>-iso.local.yml`
- Update the `host_vars/proxmox-<MACHINE>-iso.local.yml` file
- Run the playbook on the ansible controller

**Example:**

```bash
sudo date -u -s "YYYY-MM-DD HH:MM:SS"
sudo hostnamectl set-hostname proxmox-<MACHINE>-iso
sudo passwd user
nmcli dev wifi connect <SSID> password <PASSPHRASE>
sudo apt update
sudo apt install -y openssh-server
sudo systemctl restart ssh avahi-daemon

sudo wipefs -af /dev/sda?
sudo /sbin/vgchange -an
sudo /sbin/dmsetup remove_all --force
```
