# Install SSH Server
sudo apt install openssh-server
sudo systemctl enable sshd

# Generate Key
ssh-keygen -b 4096 -t rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Uncomment "PubkeyAuthentication yes" in
sudo nano /etc/ssh/sshd_config

# Restart SSH Services
sudo systemctl restart sshd
sudo systemctl restart ssh
