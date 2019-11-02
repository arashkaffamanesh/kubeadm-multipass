#!/bin/bash
set -e
containerdVersion=1.3.0


function welcome_to_demo {
echo 'welcome to CRI and Kubernetes demo'
}
function install_tools {
sudo apt-get update && sudo apt-get install -y libseccomp2 apt-transport-https curl
## add key
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
## add repository
sudo touch /etc/apt/sources.list.d/kubernetes.list
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
}

function download_containerd_tarball {
echo 'downloading  containerd 1.3.0..'
sudo wget https://storage.googleapis.com/cri-containerd-release/cri-containerd-${containerdVersion}.linux-amd64.tar.gz
}

function verify_checksum {
localSha=$(sha256sum cri-containerd-${containerdVersion}.linux-amd64.tar.gz | awk '{ print $1 }')
remoteSha=$(curl https://storage.googleapis.com/cri-containerd-release/cri-containerd-${containerdVersion}.linux-amd64.tar.gz.sha256)
if [ $localSha = $remoteSha ]
then
  echo 'containerd tarball is valid :)'
else
  echo 'containerd tarball is not valid :('
fi
}

function setup_containerd {
echo 'the tarball is composed from :'
sudo tar -tf cri-containerd-${containerdVersion}.linux-amd64.tar.gz
sudo tar --no-overwrite-dir -C / -xzf cri-containerd-${containerdVersion}.linux-amd64.tar.gz
sudo systemctl start containerd
}

function create_containerd_kubelet_conf {
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service.d/0-containerd.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--container-runtime=remote --runtime-request-timeout=15m --container-runtime-endpoint=unix:///run/containerd/containerd.sock"
EOF
sudo systemctl daemon-reload
}

function bring_up_cluster {
sudo modprobe br_netfilter
sudo sysctl net.bridge.bridge-nf-call-iptables=1
echo 1 |  sudo tee  /proc/sys/net/ipv4/ip_forward
sudo kubeadm init
}

function setup_kubectl_conf {
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

function enbale_pod_scheduling_on_master {
kubectl taint nodes --all node-role.kubernetes.io/master-
}

function setup_network {
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
}

"$@"
