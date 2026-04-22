# Install Ubuntu

- Download [ubuntu](https://ubuntu.com/download/alternative-downloads)
- Format a USB
- Unmount disk (on MacOS ex. `diskutil unmountDisk /dev/diskX`)
- Create bootable image from iso `sudo dd if=/path/to/image.iso of=/dev/diskX bs=4M status=progress`
- Boot the `ubuntu` live image from a bootable USB
- Connect to wireless network (if not connected via LAN)
- Set root password (which will be asked to run the install playbook)
- Set the host name `ubuntu-<MACHINE>-iso.local`
- Install and configure ssh
- `cp host_vars/ubuntu-<MACHINE>-iso.local.example host_vars/ubuntu-<MACHINE>-iso.local`
- Update the `host_vars/ubuntu-<MACHINE>-iso.local` file
- Run the playbook on the ansible controller

**Example:**

```bash
sudo hostnamectl set-hostname ubuntu-<MACHINE>-iso
passwd
nmcli dev wifi connect <SSID> password <PASSPHRASE>
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y openssh-server
sudo systemctl restart ssh avahi-daemon
```

**Mac Example:**

On a machine with internet connection, download the Apple missing drivers dependencies

- Get the kernel version from the live ISO (ex. `uname -r`)
- Use the kernel version to download dependencies (ex. `./hack/ubuntu/mac-drivers.sh 6.11.0-17-generic`)
- Copy downloaded dependencies (in `/tmp/bcmwl-drivers`) to the USB

On the Ubuntu Live ISO

```bash
sudo mkdir /media/usb
lsblk
sudo mount /dev/sdX1 /media/usb
cp -r /media/usb/bcmwl-drivers /tmp/bcmwl
bash /tmp/bcmwl/install-wl.sh  /tmp/bcmwl

ip link
hostnamectl set-hostname ubuntu-macbook-iso.local
passwd
nmcli dev wifi connect <SSID> password <PASSPHRASE>
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y openssh-server
sudo systemctl restart ssh avahi-daemon
```
