#!/bin/bash
multipass launch ubuntu --name master --cpus 2 --mem 2G --disk 8G
multipass exec master -- bash -c 'wget https://packages.cloud.google.com/apt/doc/apt-key.gpg'
multipass exec master -- bash -c 'sudo apt-key add apt-key.gpg'
multipass exec master -- bash -c 'sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"'
multipass exec master -- bash -c 'sudo apt-get update && apt-get install -y apt-transport-https'
multipass exec master -- bash -c 'curl https://releases.rancher.com/install-docker/18.09.sh | sh'
# Setup daemon.
multipass transfer daemon.json master:/home/multipass/
multipass exec master -- bash -c 'sudo cp /home/multipass/daemon.json /etc/docker/daemon.json'
multipass exec master -- bash -c 'sudo mkdir -p /etc/systemd/system/docker.service.d'
# Restart docker.
multipass exec master -- bash -c 'sudo systemctl daemon-reload'
multipass exec master -- bash -c 'sudo systemctl restart docker'
multipass exec master -- bash -c 'sudo usermod -aG docker multipass'
multipass exec master -- bash -c 'sudo apt-get install -y kubelet kubeadm kubectl'
multipass exec master -- bash -c 'sudo apt-mark hold kubelet kubeadm kubectl'
multipass exec master -- bash -c 'sudo swapoff -a'
multipass exec master -- bash -c 'sudo sysctl net.bridge.bridge-nf-call-iptables=1'
multipass exec master -- bash -c 'sudo kubeadm init --pod-network-cidr=192.178.0.0/16'
multipass exec master -- bash -c 'sudo cat /etc/kubernetes/admin.conf' > kubeconfig.yaml
KUBECONFIG=kubeconfig.yaml
# kubectl apply -f https://docs.projectcalico.org/v3.9/manifests/calico.yaml
kubectl apply -f calico.yaml
kubectl rollout status daemonset calico-node -n kube-system
kubectl get nodes -o wide
echo "Enjoy the kubeadm made Kubernetes 1.6 on Multipass"
echo "Please take a note of the kubeadm join command above"
echo "You should now run ./2-deploy-kubeadm-nodes.sh to build a multi-node cluster"