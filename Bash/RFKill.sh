# 1. Update package list and upgrade any existing packages.
sudo apt update
sudo apt full-upgrade

# 2. Ensure rfkill is installed by running the following command.
sudo apt install rfkill

# 3. With rfkill installed, you can easily use it to disable the Wi-Fi interface.
# All you need to do is enter the following command, where we are using rfkill‘s block command followed by “wifi“.
sudo rfkill block wifi
# You can also use rfkill to disable your Bluetooth connection as well.
sudo rfkill block bluetooth

# 4. Your Wi-Fi connection should now be successfully disabled.
# If you ever want to restore the functionality to your connection, you can run the following command.
sudo rfkill unblock wifi

# Modifying the Boot Config to Disable Wi-Fi connection during the start-up sequence.
# 1. You can do so by running the following command.
sudo nano /boot/config.txt

# 2. Within this section, find the following block of text.
# You can use the CTRL + W shortcut to search the text file when using nano.
[all]

# 3. Below this text, you need to add the following lines.
# This line tells the system that it needs to disable the Wi-Fi module.
dtoverlay=disable-wifi
# You can also use this file to disable the Bluetooth module by adding the following line.
dtoverlay=disable-bt

# 4. You can now save the changes to the configuration file.
"CTRL + O", followed by the "ENTER" key, then "CTRL + X".

# 5. For this change to take effect, you will need to restart.
# To safely reboot the device, you can use the following command.
sudo reboot

# Blocking Wi-Fi using the Modprobe Blacklist
# Modprobe is a special piece of software used to load kernel modules into the Linux kernel itself.
# We can use a feature of modprobe to block it from loading in the kernel modules used for the Wi-Fi or Bluetooth connections.
# 1. On your Raspberry Pi, run the following command to edit the “raspi-blacklist.conf” file.
# The modprobe software automatically reads in this config file.
sudo nano /etc/modprobe.d/raspi-blacklist.conf

# 2. Within this file, we can add the following two lines to the bottom of it to disable the Wi-Fi kernel modules from being loaded in.
# All this does is tells modprobe that it can’t load in the kernel modules starting with the specified name.
blacklist brcmfmac
blacklist brcmutil

# If you would like to disable the Bluetooth module from loading, you can add the following lines.
blacklist hci_uart
blacklist btbcm
blacklist btintel
blacklist rfcom
blacklist btqca
blacklist btsdio
blacklist bluetooth

# 3. Once you have the blacklist lines added to the file, you need to save it.
"CTRL + O", followed by the "ENTER" key, then "CTRL + X".

# 4. For the changes to take effect, you will need to restart your Raspberry Pi.
# To restart your Pi use the following command.
sudo reboot
