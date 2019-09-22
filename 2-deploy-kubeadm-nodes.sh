#!/bin/bash
NODES=$(echo worker{1..2})
for NODE in ${NODES}; do multipass launch --name ${NODE} --cpus 2 --mem 2G --disk 8G; done

for NODE in ${NODES}; do
multipass exec ${NODE} -- bash -c 'wget https://packages.cloud.google.com/apt/doc/apt-key.gpg'
multipass exec ${NODE} -- bash -c 'sudo apt-key add apt-key.gpg'
multipass exec ${NODE} -- bash -c 'sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"'
multipass exec ${NODE} -- bash -c 'sudo apt-get update && apt-get install -y apt-transport-https'
multipass exec ${NODE} -- bash -c 'curl https://releases.rancher.com/install-docker/18.09.sh | sh'
# Setup daemon.
multipass transfer daemon.json ${NODE}:/home/multipass/
multipass exec ${NODE} -- bash -c 'sudo cp /home/multipass/daemon.json /etc/docker/daemon.json'
multipass exec ${NODE} -- bash -c 'sudo mkdir -p /etc/systemd/system/docker.service.d'
# Restart docker.
multipass exec ${NODE} -- bash -c 'sudo systemctl daemon-reload'
multipass exec ${NODE} -- bash -c 'sudo systemctl restart docker'
multipass exec ${NODE} -- bash -c 'sudo usermod -aG docker multipass'
multipass exec ${NODE} -- bash -c 'sudo apt-get install -y kubelet kubeadm kubectl'
# multipass exec ${NODE} -- bash -c 'sudo apt-mark hold kubelet kubeadm kubectl'
multipass exec ${NODE} -- bash -c 'sudo swapoff -a'
multipass exec ${NODE} -- bash -c 'sudo sysctl net.bridge.bridge-nf-call-iptables=1'
done

echo "Now run multipass shell worker1 and run the kuneadm join command with sudo on the nodes"
echo "something like this:"
echo "sudo kubeadm join 192.168.64.33:6443 --token akedou.fej8ghxu0vmud4zl --discovery-token-ca-cert-hash ....."
echo "and lable your worker nodes with"
echo "kubectl label node worker1 node-role.kubernetes.io/node="
echo "kubectl label node worker2 node-role.kubernetes.io/node="
echo "What does kubectl get nodes -o wide say?"

# todo: try to automate 
# sudo kubeadm join 192.168.64.33:6443 --token akedou.fej8ghxu0vmud4zl --discovery-token-ca-cert-hash sha256:0154b595e6f5fafa7e2a640ea36936482a834da4805b19ed780996397c57bfe5
# kubectl label node worker1 node-role.kubernetes.io/node=
# kubectl label node worker2 node-role.kubernetes.io/node=