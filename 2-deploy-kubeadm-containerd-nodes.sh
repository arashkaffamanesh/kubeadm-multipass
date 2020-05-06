#!/bin/bash
NODES=$(echo worker{1..2})
for NODE in ${NODES}; do multipass launch --name ${NODE} --cpus 2 --mem 2G --disk 8G; done
for NODE in ${NODES}; do
multipass transfer install_tools.sh ${NODE}:
multipass exec ${NODE} -- bash -c 'cd $HOME'
multipass exec ${NODE} -- bash -c 'sudo chmod +x $HOME/install_tools.sh'
multipass exec ${NODE} -- bash -c './install_tools.sh install_tools'
multipass exec ${NODE} -- bash -c './install_tools.sh download_containerd_tarball'
multipass exec ${NODE} -- bash -c './install_tools.sh verify_checksum'
multipass exec ${NODE} -- bash -c './install_tools.sh setup_containerd'
multipass exec ${NODE} -- bash -c './install_tools.sh create_containerd_kubelet_conf'
multipass exec ${NODE} -- bash -c 'sudo swapoff -a'
multipass exec ${NODE} -- bash -c  "sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab"
multipass exec ${NODE} -- bash -c  'sudo modprobe br_netfilter'
multipass exec ${NODE} -- bash -c 'sudo sysctl net.bridge.bridge-nf-call-iptables=1'
multipass exec ${NODE} -- bash -c 'sudo echo 1 |  sudo tee  /proc/sys/net/ipv4/ip_forward'
multipass exec ${NODE} -- bash -c 'sudo systemctl enable kubelet.service'
done

echo "Now running kubeadm join nodes"
echo "We're ready soon :-)"