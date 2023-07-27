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

#To install MongoDB on Ubuntu

#Import the public key used by the package management system
sudo apt-get install gnupg
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
   --dearmor

#Create a list file for MongoDB
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

#Reload local package database
sudo apt-get update

#Install the MongoDB packages
sudo apt-get install -y mongodb-org

#MongoDB recommends you disable Transparent Huge Pages

#Create the systemd unit file
sudo nano /etc/systemd/system/disable-transparent-huge-pages.service

[Unit]
Description=Disable Transparent Huge Pages (THP)
DefaultDependencies=no
After=sysinit.target local-fs.target
Before=mongod.service

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo never | tee /sys/kernel/mm/transparent_hugepage/enabled > /dev/null'

[Install]
WantedBy=basic.target

#Reload systemd unit files
sudo systemctl daemon-reload

#Start the service
sudo systemctl start disable-transparent-huge-pages
cat /sys/kernel/mm/transparent_hugepage/enabled

#Configure your operating system to run it on boot
sudo systemctl enable disable-transparent-huge-pages

#You can use a keyserver approach via a widget if you wish to incorporate proxies and other non-free environments
wget -qO- 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0xf5679a222c647c87527c2f8cb00a0bd1e2c63c11' | sudo apt-key add -

# Enable MongoDB during the operating system’s start up and verify it is running
sudo systemctl daemon-reload
sudo systemctl enable mongod.service
sudo systemctl restart mongod.service
sudo systemctl --type=service --state=active | grep mongod

#Elasticsearch

#Elasticsearch 7.10.2 is the only version that is compatible with Graylog 5.0
wget -q https://artifacts.elastic.co/GPG-KEY-elasticsearch -O myKey
sudo apt-key add myKey
echo "deb https://artifacts.elastic.co/packages/oss-7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update && sudo apt-get install elasticsearch-oss

#Modify the Elasticsearch configuration file
sudo tee -a /etc/elasticsearch/elasticsearch.yml > /dev/null <<EOT
cluster.name: graylog
action.auto_create_index: false
EOT

#start Elasticsearch and verify it is running
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl restart elasticsearch.service
sudo systemctl --type=service --state=active | grep elasticsearch

#Graylog

#Install the Graylog Open repository configuration and Graylog
wget https://packages.graylog2.org/repo/packages/graylog-5.0-repository_latest.deb
sudo dpkg -i graylog-5.0-repository_latest.deb
sudo apt-get update && sudo apt-get install graylog-server

#Edit the Configuration File

#Read the instructions within the configurations file and edit as needed, located at /etc/graylog/server/server.conf. Additionally add password_secret and root_password_sha2 as these are mandatory and Graylog will not start without them.
#To create your root_password_sha2
echo -n "Enter Password: " && head -1 </dev/stdin | tr -d '\n' | sha256sum | cut -d" " -f1

#You will then need to use the following command to create your root_password_sha2
#< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c${1:-96};echo;

#To be able to connect to Graylog, set http_bind_address to the public host name or a public IP address of the machine with which you can connect
sudo nano /etc/graylog/server/server.conf

#The last step is to enable Graylog during the operating system’s startup
sudo systemctl daemon-reload
sudo systemctl enable graylog-server.service
sudo systemctl start graylog-server.service
sudo systemctl --type=service --state=active | grep graylog
