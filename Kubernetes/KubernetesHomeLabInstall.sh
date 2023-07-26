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

#1. Install Docker Container Runtime
sudo apt install docker.io

#Create and Add user to docker group
sudo usermod -aG docker $USER && newgrp docker

#You will want to change Docker daemon to use systemd for the management of the container’s cgroups. To do this, after installing Docker, run the following:
cat <<EOF | sudo tee /etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m"
    },
    "storage-driver": "overlay2"
}
EOF

#Restart your Docker services
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker

#2. Downloads the Google Cloud public signing key, adds the Kubernetes apt repo, and installs kubelet, kubeadm, and kubectl.
sudo apt update && sudo apt upgrade -y
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -qy kubelet=1.23.1-00 kubectl=1.23.1-00 kubeadm=1.23.1-00
sudo apt-mark hold kubelet kubeadm kubectl

kubeadm config images pull

sudo swapoff -a
#Comment out swap line
sudo nano /etc/fstab
mount -a

#3. Initialize the Kubernetes Cluster (MASTER NODE ONLY)
#After installing kubeadm, we can use it to initialize the Kubernetes cluster. To do that, use the following command:
#kubeadm init --pod-network-cidr=<your pods CIDR>
#Example:  kubeadm init --pod-network-cidr=10.244.0.0/16
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=Mem

#Your Kubernetes control-plane has initialized successfully!
#To start using your cluster, you need to run the following as a regular user:
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config

#Alternatively, if you are the root user, you can run:
    # export KUBECONFIG=/etc/kubernetes/admin.conf

#You should now deploy a pod network to the cluster.
#Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
    ##https://kubernetes.io/docs/concepts/cluster-administration/addons/

#Then you can join any number of worker nodes by running the following on each as root:
# kubeadm join [IPADDRESS]:6443 --token [TOKEN] \
# --discovery-token-ca-cert-hash sha256:[SHA256TOEKN]
#Exporting the config and copying the command to join kubernetes worker nodesExporting the config and copying the command to join kubernetes worker nodes

#Flannel network
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
#Setting up the flannel container network pluginSetting up the flannel container network plugin

#4. Join Worker Nodes
sudo mkdir -p $HOME/.kube

#Copy .kube/config from master node
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

sudo kubeadm join [IPADDRESS]:6443 --token [TOKEN] --discovery-token-ca-cert-hash sha256:[SHA256TOEKN]

kubectl label nodes [HOSTNAME] kubernetes.io/role=worker
kubectl label nodes [HOSTNAME] kubernetes.io/role=worker

kubectl get nodes
kubectl get pods --all-namespaces
kubectl cluster-info

#5. Install the Kubernetes Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
#Deploy the kubernetes dashboard using the official yaml scriptDeploy the kubernetes dashboard using the official yaml script

#Setup Nodeport networking by editing the kubernetes-dashboard svc. To do that, run the command:
kubectl -n kubernetes-dashboard edit svc kubernetes-dashboard
# Edit the type to NodePort and add the nodePort section under ports. Choose an arbitrary port been 30000-32767.
# Editing the kubernetes dashboard service for nodeport connectivityEditing the kubernetes dashboard service for nodeport connectivity

# Verify the Kubernetes-dashboard service using:
kubectl -n kubernetes-dashboard get svc

# Create a Service Account in the namespace kubernetes-dashboard
# dashboard-adminuser.yaml 
kubectl apply -f dashboard-adminuser.yaml

# ClusterRoleBinding.yaml
kubectl apply -f ClusterRoleBinding.yaml

# Get a bearer token for the new account, which you can use to log in. Use the following command (in one line). The command uses the account name in the example above, admin-user
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"

#Copy the token from the console and paste it into the Enter token field on the Kubernetes Dashboard login screen. Click Sign in to log into the dashboard as administrator.
[TOKEN]
https://[IPADDRESS]:[PORTNUMBER]


kubectl run nginx --image=nginx

kubectl get pods -l run=nginx

#Read how to place an Avi Load Balancer (NSX Advanced Load Balancer) in Standalone mode in front of the Kubernetes cluster here:
    #Avi Load Balancer VMware Standalone Install
    #https://www.virtualizationhowto.com/2021/06/avi-load-balancer-vmware-standalone-install/


#for when I mess up
swapoff -a
sudo kubeadm reset
sudo systemctl daemon-reload
sudo systemctl restart kubelet

sudo apt purge kubectl kubeadm kubelet
sudo apt autoremove
sudo rm -fr /etc/kubernetes/; sudo rm -fr ~/.kube/; sudo rm -fr /var/lib/etcd; sudo rm -rf /var/lib/cni/
sudo systemctl daemon-reload
sudo apt-get install -qy kubelet=1.23.1-00 kubectl=1.23.1-00 kubeadm=1.23.1-00

# REBOOTING CLUSTER 
#https://stackoverflow.com/questions/33671449/how-to-restart-kubernetes-nodes
#Start with the master node then work nodes
    #(Optional) Swap off
    swapoff -a
    #You have to restart all Docker containers
    docker restart $(docker ps -a -q)
    #Check the nodes status after you performed step 1 and 2 on all nodes (the status is NotReady)
    kubectl get nodes
    kubectl get pods --all-namespaces
    #Restart the node
    systemctl restart kubelet
    #Check again the status (now should be in Ready status)
#Note: It will take a little bit to change the node state from NotReady to Ready
