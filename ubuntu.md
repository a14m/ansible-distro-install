# Install Ubuntu

- Download [ubuntu](https://ubuntu.com/download/alternative-downloads)
- Format a USB
- Unmount disk (on MacOS ex. `diskutil unmountDisk /dev/diskX`)
- Create bootable image from iso `sudo dd if=/path/to/image.iso of=/dev/diskX bs=4M status=progress`
- Boot the `ubuntu` live image from a bootable USB
- Connect to wireless network (if not connected via LAN)
- Set root password (which will be asked to run the install playbook)
- Set the hostname to `ubuntuiso.local`
- Install and configure ssh
- `cp host_vars/ubuntuiso.local.example host_vars/ubuntuiso.local`
- Update the `host_vars/ubuntuiso.local` file
- Run the playbook on the ansible controller

**Example:**

```bash
passwd
nmcli dev wifi connect <SSID> password <PASSPHRASE>
sudo hostnamectl set-hostname ubuntuiso
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y openssh-server
sudo systemctl restart ssh avahi-daemon
```
