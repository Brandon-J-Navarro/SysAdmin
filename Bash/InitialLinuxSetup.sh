#Protect Linux Server
#SOURCE: https://learn.networkchuck.com/courses/take/ad-free-youtube-videos/lessons/22626695-protect-your-linux-server-from-hackers-5-step

#STEP 1 - Enable Automatic Updates
#Manual Updates:
sudo apt update
sudo apt dist-upgrade

#Automatic Updates:
sudo apt install unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades


#STEP 2 - Create a Limited User Account
#Create a User:
adduser {username}

#Add user to the sudo group:
usermod -aG sudo {username}

#STEP 3 - Passwords are for SUCKERS!
#Create the Public Key Directory on your Linux Server
mkdir ~/.ssh && chmod 700 ~/.ssh

#Create Public/Private keys on your computer
ssh-keygen -b 4096

#Upload your Public key to the your Linux Server (Windows)
scp $env:USERPROFILE/.ssh/id_rsa.pub {username}@{server ip}:~/.ssh/authorized_keys

#Upload your Public key to the your Linux Server (MAC)
scp ~/.ssh/id_rsa.pub {username}@{server ip}:~/.ssh/authorized_keys

#Upload your Public key to the your Linux Server (LINUX)
ssh-copy-id {username}@{server ip}

#STEP 4 - Lockdown Logins
#Edit the SSH config file
sudo nano /etc/ssh/sshd_config


#STEP 5 - FIREWALL IT UP
#See open ports
sudo ss -tupln

#Install UFW
apt install ufw

#See UFW status
sudo ufw status

#Allow port through firewall
sudo ufw allow {port number}

#Enable Firewall
sudo ufw enable

#Reload Firewall
sudo ufw reload

#Drop pings
#Edit the UFW config file
sudo nano /etc/ufw/before.rules

#Add this line of config:
-A ufw-before-input -p icmp --icmp-type echo-request -j DROP
