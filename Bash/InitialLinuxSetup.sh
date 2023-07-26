# Released under MIT License

# Copyright (c) 2023 Brandon J. Navarro

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#Manual Updates:
sudo apt update
sudo apt dist-upgrade

#Automatic Updates:
sudo apt install unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades

#Create a User:
adduser [USERNAME]

#Add user to the sudo group:
usermod -aG sudo [USERNAME]

#Create the Public Key Directory on your Linux Server
mkdir ~/.ssh && chmod 700 ~/.ssh

#Create Public/Private keys on your computer
ssh-keygen -b 4096

#Upload your Public key to the your Linux Server (Windows)
scp $env:USERPROFILE/.ssh/id_rsa.pub [USERNAME]@[IPADDRESS]:~/.ssh/authorized_keys

#Upload your Public key to the your Linux Server (MAC)
scp ~/.ssh/id_rsa.pub [USERNAME]@[IPADDRESS]:~/.ssh/authorized_keys

#Upload your Public key to the your Linux Server (LINUX)
ssh-copy-id [USERNAME]@[IPADDRESS]

#Edit the SSH config file
sudo nano /etc/ssh/sshd_config

#See open ports
sudo ss -tupln

#Install UFW
apt install ufw

#See UFW status
sudo ufw status

#Allow port through firewall
sudo ufw allow [PORTNUMBER]

#Enable Firewall
sudo ufw enable

#Reload Firewall
sudo ufw reload

#Edit the UFW config file to drop pings
sudo nano /etc/ufw/before.rules
#Add this line of config:
-A ufw-before-input -p icmp --icmp-type echo-request -j DROP
