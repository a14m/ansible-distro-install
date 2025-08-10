# Install Raspberry Pi 5

- Download [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
- Create a bootable USB using the imager
  - OS: Raspberry PI OS LITE
  - Hostname: `raspberryiso`
  - Username/Password: `pi:raspberry`
  - Enable SSH (Use password authentication)
- Turn off the raspberry pi and remove the SD card
- Insert the bootable USB and turn the PI
- Wait for the PI to start
- SSH into the PI using the username/password configured
- Insert the SD Card
- Make sure the PI boot order is set to `BOOT_ORDER=0x1f461` using `sudo rpi-eeprom-config --edit`
