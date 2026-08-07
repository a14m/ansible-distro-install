# Install Raspberry Pi 5

- Download [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
- Create a bootable USB using the imager
  - OS: Raspberry PI OS LITE
  - Hostname: `rpi<Version>-iso`
  - Username/Password: `pi:<Password>`
  - Enable SSH (Use password authentication)
- Turn off the raspberry pi and remove the SD card
- Insert the bootable USB and turn the PI
- Wait for the PI to start
- SSH into the PI using the username/password configured
- Insert the SD Card
- Make sure the PI boot order is set to `BOOT_ORDER=0x1f461` using `sudo rpi-eeprom-config --edit`

## Router Setup (Disable Pi-hole)

- Home Network > Network > Network Settings > Change Advanced Settings > IPv4 > DHCP > Enable DHCP Server
- Internet > Filter > Standard > Blocked applications > DNS > Edit > Remove
- Internet > Account Information > DNS Server >
  - Use DNSv4 server assigned by ISP
  - Use DNSv6 server assigned by ISP
