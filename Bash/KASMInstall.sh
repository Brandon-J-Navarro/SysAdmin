# Copyright 2023, Kasm Technologies.
# SOURCE: https://kasmweb.com/docs/latest/install/single_server_install.html

#Swap file
sudo dd if=/dev/zero bs=1M count=1024 of=/mnt/1GiB.swap
sudo chmod 600 /mnt/1GiB.swap
sudo mkswap /mnt/1GiB.swap
sudo swapon /mnt/1GiB.swap
#Verify swap exists
cat /proc/swaps
#Add swap to fstab
echo '/mnt/1GiB.swap swap swap defaults 0 0' | sudo tee -a /etc/fstab
#Download the KASM set up
wget https://kasm-static-content.s3.amazonaws.com/kasm_release_1.10.0.238225.tar.gz
curl -O https://kasm-static-content.s3.amazonaws.com/kasm_release_1.11.0.18142e.tar.gz
#Unzip the set up files.
tar -xf kasm_release*.tar.gz
#Start the set up script.
sudo bash kasm_release/install.sh
#Uninstall
#Stop All Kasm services.
sudo /opt/kasm/current/bin/stop
#Remove any Kasm session containers.
sudo docker rm -f $(sudo docker container ls -qa --filter="label=kasm.kasmid")
sudo docker rm -f $(sudo docker container ls -qa --filter="status=exited")
#Remove Kasm service containers.
export KASM_UID=$(id kasm -u)
export KASM_GID=$(id kasm -g)
sudo -E docker compose -f /opt/kasm/current/docker/docker-compose.yaml rm
#Remove the Kasm docker network.
sudo docker network rm kasm_default_network
#Remove the Kasm database docker volume.
sudo docker volume rm kasm_db_1.11.0
#Remove the Kasm docker images.
sudo docker rmi redis:5-alpine
sudo docker rmi postgres:9.5-alpine
sudo docker rmi kasmweb/nginx:latest
sudo docker rmi kasmweb/share:1.11.0
sudo docker rmi kasmweb/agent:1.11.0
sudo docker rmi kasmweb/manager:1.11.0
sudo docker rmi kasmweb/api:1.11.0
sudo docker rmi $(sudo docker images --filter "label=com.kasmweb.image=true" -q)
#Remove the Kasm installation directory structure.
sudo rm -rf /opt/kasm/

