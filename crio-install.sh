#!/bin/bash
## Kubeadm with cri-o, flannel and podman on Ubuntu 18.04
## How to use:
## wget https://raw.githubusercontent.com/arashkaffamanesh/kubeadm-multipass/master/crio-install.sh
## chmod +x crio-install.sh
## ./crio-install.sh
## Build crio from source
git clone https://github.com/cri-o/cri-o && cd /root/cri-o
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 018BA5AD9DF57A4448F0E6CF8BECF1637AD8C79D
echo "deb http://ppa.launchpad.net/projectatomic/ppa/ubuntu bionic main" > /etc/apt/sources.list.d/crio.list
apt-add-repository ppa:projectatomic/ppa -y
apt-get update -qq && apt-get install -y runc conmon btrfs-tools containers-common git golang-go libassuan-dev libdevmapper-dev libglib2.0-dev libc6-dev libgpgme11-dev libgpg-error-dev libseccomp-dev libsystemd-dev libselinux1-dev pkg-config go-md2man cri-o-runc libudev-dev software-properties-common gcc make
go get github.com/cpuguy83/go-md2man
make BUILDTAGS=""
make install
make install.systemd
mkdir /etc/crio
cp /root/cri-o/crio.conf /etc/crio/
cp /root/cri-o/crictl.yaml /etc/
systemctl daemon-reload
systemctl start crio
# systemctl status crio.service

## Install kubeadm

modprobe overlay
modprobe br_netfilter
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system
wget https://raw.githubusercontent.com/kubernauts/kubernetes-workshop/master/cri-and-kubernetes-meetup-demo/demo-scripts/install_tools.sh
chmod +x install_tools.sh
./install_tools.sh install_tools
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
## kubeadm with flannel
kubeadm init --pod-network-cidr=10.244.0.0/16
## calico
# kubeadm init --pod-network-cidr=192.178.0.0/16

echo "##########################################"
echo "kubeadm is installed"
echo "##########################################"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
wget https://raw.githubusercontent.com/arashkaffamanesh/kubeadm-multipass/master/kube-flannel.yml
kubectl apply -f kube-flannel.yml
kubectl rollout status daemonset.apps/kube-flannel-ds-amd64 -n kube-system
## weave
# ./install_tools.sh setup_network

## Install podman
sudo apt -y  install software-properties-common
sudo apt update
sudo apt -y install podman
sudo mkdir -p /etc/containers
sudo curl https://raw.githubusercontent.com/projectatomic/registries/master/registries.fedora -o /etc/containers/registries.conf
sudo curl https://raw.githubusercontent.com/containers/skopeo/master/default-policy.json -o /etc/containers/policy.json
systemctl daemon-reload
systemctl restart crio
sleep 30

## Tets it
./install_tools.sh enbale_pod_scheduling_on_master
# crictl ps
kubectl rollout status deployment coredns -n kube-system
kubectl get nodes
kubectl run --generator=deployment/apps.v1 ghost --image ghost:latest
kubectl get pods -A
kubectl rollout status deployment ghost
kubectl get pods

echo "hope you have fun with crio and podman on kubeadm :-)"


## related links
#https://docs.cilium.io/en/v1.6/kubernetes/configuration/#crio
#https://computingforgeeks.com/how-to-install-podman-on-ubuntu/
#https://www.linode.com/docs/applications/containers/kubernetes/getting-started-with-kubernetes/
#https://launchpad.net/~projectatomic/+archive/ubuntu/ppa?field.series_filter=bionic