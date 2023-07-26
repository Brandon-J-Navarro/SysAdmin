#FROM
    #SOURCES :
        #https://www.virtualizationhowto.com/2021/06/kubernetes-home-lab-setup-step-by-step/
        #https://www.aquasec.com/cloud-native-academy/kubernetes-101/kubernetes-dashboard/
        #https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
        #https://youtu.be/_WW16Sp8-Jw

#Kubernetes Home Lab Setup Step-by-Step

#In this Kubernetes home lab setup, I will be using the following:

    #Windows 11 Pro Hyper-V (CPU i7-4770K 4C-8T, 32GB RAM, 240GB SSD Boot, 2TB SSD Storage)
    #(3) Ubuntu 22.04 server virtual machines (2vCPUs, 4096MB RAM, 127GB HDD)
    #Kubeadm to initialize and provision the Kubernetes cluster
    #Flannel as the container network interface
    #Installing the Kubernetes Dashboard

#Let’s look at the following steps to provision the Kubernetes home lab setup:

    #Install DockerIO and change Docker to Systemd
    #Install Kubeadm
    #Initialize the Kubernetes cluster
        #Export admin config
        #Provision the network overlay
    #Join worker nodes
    #Install the Kubernetes Dashboard

#1. Install Docker Container Runtime

#You need to install a container runtime into each of your Kubernetes nodes for running Pods. Docker is the most popular option, so that is what I have installed in each of my Ubuntu #22.04 virtual machines. To install Docker in Ubuntu, use the following command:

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

#2. Install Kubeadm

#Kubeadm is a tool that helps to install and configure a Kubernetes cluster in a much easier way than performing all steps manually. It helps to bootstrap a Kubernetes cluster with the necessary minimum configuration needed to get the Kubernetes cluster up and running. To install kubeadm, perform the following in Ubuntu. This updates the package index and installs packages needed to use Kubernetes apt repo, downloads the Google Cloud public signing key, adds the Kubernetes apt repo, and installs kubelet, kubeadm, and kubectl.

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

#There are many networking solutions available for Kubernetes. You can find the full list and links here: Cluster Networking | Kubernetes. The next step is to provision the network overlay. I am using the Flannel network. To use it, run the following:

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

"
    ---
    kind: Namespace
    apiVersion: v1
    metadata:
    name: kube-flannel
    labels:
        pod-security.kubernetes.io/enforce: privileged
    ---
    kind: ClusterRole
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
    name: flannel
    rules:
    - apiGroups:
    - ""
    resources:
    - pods
    verbs:
    - get
    - apiGroups:
    - ""
    resources:
    - nodes
    verbs:
    - list
    - watch
    - apiGroups:
    - ""
    resources:
    - nodes/status
    verbs:
    - patch
    ---
    kind: ClusterRoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
    name: flannel
    roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: flannel
    subjects:
    - kind: ServiceAccount
    name: flannel
    namespace: kube-flannel
    ---
    apiVersion: v1
    kind: ServiceAccount
    metadata:
    name: flannel
    namespace: kube-flannel
    ---
    kind: ConfigMap
    apiVersion: v1
    metadata:
    name: kube-flannel-cfg
    namespace: kube-flannel
    labels:
        tier: node
        app: flannel
    data:
    cni-conf.json: |
        {
        "name": "cbr0",
        "cniVersion": "0.3.1",
        "plugins": [
            {
            "type": "flannel",
            "delegate": {
                "hairpinMode": true,
                "isDefaultGateway": true
            }
            },
            {
            "type": "portmap",
            "capabilities": {
                "portMappings": true
            }
            }
        ]
        }
    net-conf.json: |
        {
        "Network": "10.244.0.0/16",
        "Backend": {
            "Type": "vxlan"
        }
        }
    ---
    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
    name: kube-flannel-ds
    namespace: kube-flannel
    labels:
        tier: node
        app: flannel
    spec:
    selector:
        matchLabels:
        app: flannel
    template:
        metadata:
        labels:
            tier: node
            app: flannel
        spec:
        affinity:
            nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                - key: kubernetes.io/os
                    operator: In
                    values:
                    - linux
        hostNetwork: true
        priorityClassName: system-node-critical
        tolerations:
        - operator: Exists
            effect: NoSchedule
        serviceAccountName: flannel
        initContainers:
        - name: install-cni-plugin
        #image: flannelcni/flannel-cni-plugin:v1.1.0 for ppc64le and mips64le (dockerhub limitations may apply)
            image: docker.io/rancher/mirrored-flannelcni-flannel-cni-plugin:v1.1.0
            command:
            - cp
            args:
            - -f
            - /flannel
            - /opt/cni/bin/flannel
            volumeMounts:
            - name: cni-plugin
            mountPath: /opt/cni/bin
        - name: install-cni
        #image: flannelcni/flannel:v0.19.2 for ppc64le and mips64le (dockerhub limitations may apply)
            image: docker.io/rancher/mirrored-flannelcni-flannel:v0.19.2
            command:
            - cp
            args:
            - -f
            - /etc/kube-flannel/cni-conf.json
            - /etc/cni/net.d/10-flannel.conflist
            volumeMounts:
            - name: cni
            mountPath: /etc/cni/net.d
            - name: flannel-cfg
            mountPath: /etc/kube-flannel/
        containers:
        - name: kube-flannel
        #image: flannelcni/flannel:v0.19.2 for ppc64le and mips64le (dockerhub limitations may apply)
            image: docker.io/rancher/mirrored-flannelcni-flannel:v0.19.2
            command:
            - /opt/bin/flanneld
            args:
            - --ip-masq
            - --kube-subnet-mgr
            resources:
            requests:
                cpu: "100m"
                memory: "50Mi"
            limits:
                cpu: "100m"
                memory: "50Mi"
            securityContext:
            privileged: false
            capabilities:
                add: ["NET_ADMIN", "NET_RAW"]
            env:
            - name: POD_NAME
            valueFrom:
                fieldRef:
                fieldPath: metadata.name
            - name: POD_NAMESPACE
            valueFrom:
                fieldRef:
                fieldPath: metadata.namespace
            - name: EVENT_QUEUE_DEPTH
            value: "5000"
            volumeMounts:
            - name: run
            mountPath: /run/flannel
            - name: flannel-cfg
            mountPath: /etc/kube-flannel/
            - name: xtables-lock
            mountPath: /run/xtables.lock
        volumes:
        - name: run
            hostPath:
            path: /run/flannel
        - name: cni-plugin
            hostPath:
            path: /opt/cni/bin
        - name: cni
            hostPath:
            path: /etc/cni/net.d
        - name: flannel-cfg
            configMap:
            name: kube-flannel-cfg
        - name: xtables-lock
            hostPath:
            path: /run/xtables.lock
            type: FileOrCreate

    "

#Setting up the flannel container network pluginSetting up the flannel container network plugin

#4. Join Worker Nodes

#To join Kubernetes worker nodes to the Kubernetes cluster, simply run the command that is displayed after you initialize the Kubernetes cluster with kubeadm. **Note** This will be run from the worker nodes. It will look something like this:

sudo mkdir -p $HOME/.kube

#sudo nano .kube/config 
"apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: [CERT]
    server: https://[IPADDRESS]:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: [CERT]
    client-key-data: [CERT]
    " | sudo tee .kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

sudo kubeadm join [IPADDRESS]:6443 --token [TOKEN] --discovery-token-ca-cert-hash sha256:[SHA256TOEKN]

kubectl label nodes [HOSTNAME] kubernetes.io/role=worker
kubectl label nodes [HOSTNAME] kubernetes.io/role=worker

#Joining a worker node to the kubernetes clusterJoining a worker node to the kubernetes cluster
#Master and two worker nodes running in the kubernetes clusterMaster and two worker nodes running in the kubernetes cluster
#After joining the workers, as you can see below, you will see Flannel pods for your workers running.
#Flannel pods up and runningFlannel pods up and running

kubectl get nodes
kubectl get pods --all-namespaces
kubectl cluster-info

#5. Install the Kubernetes Dashboard

#You most likely will want to install the Kubernetes dashboard. To install the Kubernetes Dashboard, grab the latest YAML file from here: Web UI (Dashboard) | Kubernetes

#The script will look like this:

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml

"
    # Copyright 2017 The Kubernetes Authors.
    #
    # Licensed under the Apache License, Version 2.0 (the "License");
    # you may not use this file except in compliance with the License.
    # You may obtain a copy of the License at
    #
    #     http://www.apache.org/licenses/LICENSE-2.0
    #
    # Unless required by applicable law or agreed to in writing, software
    # distributed under the License is distributed on an "AS IS" BASIS,
    # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    # See the License for the specific language governing permissions and
    # limitations under the License.

    apiVersion: v1
    kind: Namespace
    metadata:
    name: kubernetes-dashboard

    ---

    apiVersion: v1
    kind: ServiceAccount
    metadata:
    labels:
        k8s-app: kubernetes-dashboard
    name: kubernetes-dashboard
    namespace: kubernetes-dashboard

    ---

    kind: Service
    apiVersion: v1
    metadata:
    labels:
        k8s-app: kubernetes-dashboard
    name: kubernetes-dashboard
    namespace: kubernetes-dashboard
    spec:
    ports:
        - port: 443
        targetPort: 8443
    selector:
        k8s-app: kubernetes-dashboard

    ---

    apiVersion: v1
    kind: Secret
    metadata:
    labels:
        k8s-app: kubernetes-dashboard
    name: kubernetes-dashboard-certs
    namespace: kubernetes-dashboard
    type: Opaque

    ---

    apiVersion: v1
    kind: Secret
    metadata:
    labels:
        k8s-app: kubernetes-dashboard
    name: kubernetes-dashboard-csrf
    namespace: kubernetes-dashboard
    type: Opaque
    data:
    csrf: ""

    ---

    apiVersion: v1
    kind: Secret
    metadata:
    labels:
        k8s-app: kubernetes-dashboard
    name: kubernetes-dashboard-key-holder
    namespace: kubernetes-dashboard
    type: Opaque

    ---

    kind: ConfigMap
    apiVersion: v1
    metadata:
    labels:
        k8s-app: kubernetes-dashboard
    name: kubernetes-dashboard-settings
    namespace: kubernetes-dashboard

    ---

    kind: Role
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
    labels:
        k8s-app: kubernetes-dashboard
    name: kubernetes-dashboard
    namespace: kubernetes-dashboard
    rules:
    # Allow Dashboard to get, update and delete Dashboard exclusive secrets.
    - apiGroups: [""]
        resources: ["secrets"]
        resourceNames: ["kubernetes-dashboard-key-holder", "kubernetes-dashboard-certs", "kubernetes-dashboard-csrf"]
        verbs: ["get", "update", "delete"]
        # Allow Dashboard to get and update 'kubernetes-dashboard-settings' config map.
    - apiGroups: [""]
        resources: ["configmaps"]
        resourceNames: ["kubernetes-dashboard-settings"]
        verbs: ["get", "update"]
        # Allow Dashboard to get metrics.
    - apiGroups: [""]
        resources: ["services"]
        resourceNames: ["heapster", "dashboard-metrics-scraper"]
        verbs: ["proxy"]
    - apiGroups: [""]
        resources: ["services/proxy"]
        resourceNames: ["heapster", "http:heapster:", "https:heapster:", "dashboard-metrics-scraper", "http:dashboard-metrics-scraper"]
        verbs: ["get"]

    ---

    kind: ClusterRole
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
    labels:
        k8s-app: kubernetes-dashboard
    name: kubernetes-dashboard
    rules:
    # Allow Metrics Scraper to get metrics from the Metrics server
    - apiGroups: ["metrics.k8s.io"]
        resources: ["pods", "nodes"]
        verbs: ["get", "list", "watch"]

    ---

    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
    labels:
        k8s-app: kubernetes-dashboard
    name: kubernetes-dashboard
    namespace: kubernetes-dashboard
    roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: Role
    name: kubernetes-dashboard
    subjects:
    - kind: ServiceAccount
        name: kubernetes-dashboard
        namespace: kubernetes-dashboard

    ---

    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
    name: kubernetes-dashboard
    roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: kubernetes-dashboard
    subjects:
    - kind: ServiceAccount
        name: kubernetes-dashboard
        namespace: kubernetes-dashboard

    ---

    kind: Deployment
    apiVersion: apps/v1
    metadata:
    labels:
        k8s-app: kubernetes-dashboard
    name: kubernetes-dashboard
    namespace: kubernetes-dashboard
    spec:
    replicas: 1
    revisionHistoryLimit: 10
    selector:
        matchLabels:
        k8s-app: kubernetes-dashboard
    template:
        metadata:
        labels:
            k8s-app: kubernetes-dashboard
        spec:
        containers:
            - name: kubernetes-dashboard
            image: kubernetesui/dashboard:v2.2.0
            imagePullPolicy: Always
            ports:
                - containerPort: 8443
                protocol: TCP
            args:
                - --auto-generate-certificates
                - --namespace=kubernetes-dashboard
                # Uncomment the following line to manually specify Kubernetes API server Host
                # If not specified, Dashboard will attempt to auto discover the API server and connect
                # to it. Uncomment only if the default does not work.
                # - --apiserver-host=http://my-address:port
            volumeMounts:
                - name: kubernetes-dashboard-certs
                mountPath: /certs
                # Create on-disk volume to store exec logs
                - mountPath: /tmp
                name: tmp-volume
            livenessProbe:
                httpGet:
                scheme: HTTPS
                path: /
                port: 8443
                initialDelaySeconds: 30
                timeoutSeconds: 30
            securityContext:
                allowPrivilegeEscalation: false
                readOnlyRootFilesystem: true
                runAsUser: 1001
                runAsGroup: 2001
        volumes:
            - name: kubernetes-dashboard-certs
            secret:
                secretName: kubernetes-dashboard-certs
            - name: tmp-volume
            emptyDir: {}
        serviceAccountName: kubernetes-dashboard
        nodeSelector:
            "kubernetes.io/os": linux
        # Comment the following tolerations if Dashboard must not be deployed on master
        tolerations:
            - key: node-role.kubernetes.io/master
            effect: NoSchedule

    ---

    kind: Service
    apiVersion: v1
    metadata:
    labels:
        k8s-app: dashboard-metrics-scraper
    name: dashboard-metrics-scraper
    namespace: kubernetes-dashboard
    spec:
    ports:
        - port: 8000
        targetPort: 8000
    selector:
        k8s-app: dashboard-metrics-scraper

    ---

    kind: Deployment
    apiVersion: apps/v1
    metadata:
    labels:
        k8s-app: dashboard-metrics-scraper
    name: dashboard-metrics-scraper
    namespace: kubernetes-dashboard
    spec:
    replicas: 1
    revisionHistoryLimit: 10
    selector:
        matchLabels:
        k8s-app: dashboard-metrics-scraper
    template:
        metadata:
        labels:
            k8s-app: dashboard-metrics-scraper
        annotations:
            seccomp.security.alpha.kubernetes.io/pod: 'runtime/default'
        spec:
        containers:
            - name: dashboard-metrics-scraper
            image: kubernetesui/metrics-scraper:v1.0.6
            ports:
                - containerPort: 8000
                protocol: TCP
            livenessProbe:
                httpGet:
                scheme: HTTP
                path: /
                port: 8000
                initialDelaySeconds: 30
                timeoutSeconds: 30
            volumeMounts:
            - mountPath: /tmp
                name: tmp-volume
            securityContext:
                allowPrivilegeEscalation: false
                readOnlyRootFilesystem: true
                runAsUser: 1001
                runAsGroup: 2001
        serviceAccountName: kubernetes-dashboard
        nodeSelector:
            "kubernetes.io/os": linux
        # Comment the following tolerations if Dashboard must not be deployed on master
        tolerations:
            - key: node-role.kubernetes.io/master
            effect: NoSchedule
        volumes:
            - name: tmp-volume
            emptyDir: {}
"

#Deploy the kubernetes dashboard using the official yaml scriptDeploy the kubernetes dashboard using the official yaml script

#Setup Nodeport networking by editing the kubernetes-dashboard svc. To do that, run the command:

kubectl -n kubernetes-dashboard edit svc kubernetes-dashboard
    # Please edit the object below. Lines beginning with a '#' will be ignored,
    # and an empty file will abort the edit. If an error occurs while saving this file will be
    # reopened with the relevant failures.
    #
    apiVersion: v1
    kind: Service
    metadata:
    annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"labels":{"k8s-app":"kubernetes-dashboard"},"name":"kubernetes-dashboard","namespace":"kubernetes-dashboard"},"spec":{"ports":[{"port":443,"targetPort":8443}],"selector":{"k8s-app":"kubernetes-dashboard"}}}
    creationTimestamp: "2022-09-26T18:38:50Z"
    labels:
    k8s-app: kubernetes-dashboard
    name: kubernetes-dashboard
    namespace: kubernetes-dashboard
    resourceVersion: "6762"
    uid: c1552fc3-1824-4506-ae6a-d87916bd1157
    spec:
    clusterIP: 10.104.103.2
    clusterIPs:
    - 10.104.103.2
    externalTrafficPolicy: Cluster
    internalTrafficPolicy: Cluster
    ipFamilies:
    - IPv4
    ipFamilyPolicy: SingleStack
    ports:
    - nodePort: [PORTNUMBER]
    port: 443
    protocol: TCP
    targetPort: 8443
    selector:
    k8s-app: kubernetes-dashboard
    sessionAffinity: None
    type: NodePort
    status:
    loadBalancer: {}
#Edit the type to NodePort and add the nodePort section under ports. Choose an arbitrary port been 30000-32767.

#"ctrl+i" to insert text | "esc" to exit edit mode | ":wq" to write and quit | ":q!" to quit with out changes

#Editing the kubernetes dashboard service for nodeport connectivityEditing the kubernetes dashboard service for nodeport connectivity

#Verify the Kubernetes-dashboard service using:

kubectl -n kubernetes-dashboard get svc

#Create a Service Account in the namespace kubernetes-dashboard

#dashboard-adminuser.yaml 
echo "apiVersion: v1
kind: ServiceAccount
metadata:
    name: admin-user
    namespace: kubernetes-dashboard" | sudo tee dashboard-adminuser.yaml 

kubectl apply -f dashboard-adminuser.yaml

#We’ll assume a cluster-admin ClusterRole already exists in your cluster. Use the following code to bind the new account to it, using a ClusterRoleBinding. If there is no such role, create it and grant the required privileges. 

#ClusterRoleBinding.yaml
echo "apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
    name: admin-user
roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: admin-user
    namespace: kubernetes-dashboard" | sudo tee ClusterRoleBinding.yaml

kubectl apply -f ClusterRoleBinding.yaml

#Get a bearer token for the new account, which you can use to log in. Use the following command (in one line). The command uses the account name in the example above, admin-user

kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"

#Copy the token from the console and paste it into the Enter token field on the Kubernetes Dashboard login screen. Click Sign in to log into the dashboard as administrator.

[TOKEN]
https://[IPADDRESS]:[PORTNUMBER]

#Verifying the kubernetes dashboard service afterwardsVerifying the kubernetes dashboard service afterwards
#Accessing the kubernetes dashboard from the nodeportAccessing the kubernetes dashboard from the nodeport

#This post has walked through a basic quick configuration of getting a Kubernetes home lab setup step-by-step with a few commands to run. Keep in mind using this approach you need to have your own VMs that will serve as Kubernetes worker nodes as well as the control node or master. Look for additional Kubernetes home lab setup step-by-step guides as I will cover the Dashboard further, as well as bringing in additional workloads.

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

#In my case I am running 3 nodes in VM's by using Hyper-V. By using the following steps I was able to "restart" the cluster after restarting all VM's.
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
#Note: I do not know if it does metter the order of nodes restarting, but I choose to start with the k8s master node and after with the minions. Also it will take a little bit to change the node state from NotReady to Ready
