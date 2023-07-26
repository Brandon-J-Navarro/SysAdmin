#https://cockpit-project.org/guide/latest/listen.html
sudo apt install cockpit
sudo mkdir /etc/systemd/system/cockpit.socket.d
sudo touch /etc/systemd/system/cockpit.socket.d/listen.conf

#echo 'some text here' | sudo tee -a /path/to/file
echo '[Socket]
ListenStream=
ListenStream=8443' | sudo tee -a /etc/systemd/system/cockpit.socket.d/listen.conf

# [Socket]
# ListenStream=
# ListenStream=7777
# ListenStream=192.168.1.1:443
# FreeBind=yes

sudo systemctl daemon-reload
sudo systemctl enable cockpit.socket
sudo systemctl restart cockpit.socket
