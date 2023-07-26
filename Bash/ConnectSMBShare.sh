#Step 1: Install the CIFS Utils pkg
sudo apt-get install cifs-utils

#Step 2: Create a mount point
sudo mkdir /mnt/[LOCALFILEPATH]

#Step 3: Mount the volume
sudo mount -t cifs //[IPADDRESS]/[REMOTESHARENAME] /mnt/[LOCALFILEPATH] -o user=[USERNAME]

#Step 4: Automount volume
sudo nano /etc/fstab
#add following to the end
//[IPADDRESS]/[REMOTESHARENAME] /mnt/[LOCALFILEPATH] cifs uid=0,credentials=[CREDENTIALFILEPATH],iocharset=utf8,vers=3.0,noperm 0 0

#Step 5: Make credential file
sudo nano ~/.smb
user=[USERNAME]
password=[PASSWORD]
domain=[DOMAIN] #IF APPLICABLE
