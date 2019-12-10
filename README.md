# Multi-Node Kubernetes 1.17 with kubeadm on local multipass cloud with Docker, Containerd or CRI-O and Rancher Server on top

These simple scripts deploy a multi-node Kubernetes 1.16.2 with kubeadm on multipass VMs with Containerd, Docker or CRI-O on your local machine in about 6 minutes, depending on your internet speed.

## About Multipass

https://multipass.run/

## Prerequsists

You need kubectl and multipass installed on your laptop.

### Install multipass (on MacOS Catalina or Linux)

Multipass v0.9 RC has been updated for MacOS Catalina, please download this release:

https://github.com/CanonicalLtd/multipass/releases


```bash
wget https://github.com/CanonicalLtd/multipass/releases/download/v0.9.0-rc/multipass-0.9.0-rc.425+g37fa4305.mac-Darwin.pkg
sudo installer -target / -verbose -pkg multipass-0.9.0-rc.425+g37fa4305.mac-Darwin.pkg
snap install multipass --channel beta/0.9 --classic
```

### Install on MacOS Mojave

Please checkout the mojave branch:

```bash
git clone https://github.com/arashkaffamanesh/multipass-rke-rancher.git -b mojave-multipass-0.8
```

## Installation (3 node with docker)

Deploy the master node, 2 worker nodes and join the worker nodes into the cluster step by step:

```bash
./1-deploy-kubeadm-matser.sh
./2-deploy-kubeadm-nodes.sh
./3-kubeadm_join_nodes.sh
```

or deploy with a single command:

```bash
./deploy.sh
```

## Installation (3 node with containerd)

Deploy the master node, 2 worker nodes and join the worker nodes into the cluster step by step:

```bash
./1-deploy-kubeadm-containerd-master.sh
./2-deploy-kubeadm-containerd-nodes.sh
./3-kubeadm_join_nodes.sh
```

or deploy with a single command:

```bash
./deploy-bonsai-containerd.sh
```

You should get something similar to this at the end:

```bash
NAME      STATUS   ROLES    AGE     VERSION
master    Ready    master   6m24s   v1.16.2
worker1   Ready    node     42s     v1.16.2
worker2   Ready    node     32s     v1.16.2
############################################################################
Enjoy and learn to love learning :-)
Total runtime in minutes was: 06:30
############################################################################
```

## Just for fun (kubeadm with CRI-O)

Launch a single Ubuntu VM with multipass and try CRI-O with kubeadm and podman:

```bash
multipass launch ubuntu --name master --cpus 2 --mem 2G --disk 8G
multipass shell master
sudo -i
wget https://raw.githubusercontent.com/arashkaffamanesh/kubeadm-multipass/master/crio-install.sh
chmod +x crio-install.sh
./crio-install.sh
```

## Deploy Rancher Server

You can deploy Rancher Server on top your kubeadm cluster with:

```bash
./4-deploy-rancher-on-kubeadm.sh
```

That's it :-)


## Troubleshooting

Note: we're using Calico here, if 192.178.0.0/16 is already in use within your network you must select a different pod network CIDR, replacing 192.178.0.0/16 in the kubeadm init command in `./1-deploy-kubeadm-matser.sh` script as well as in the `calico.yaml` file provided in this repo.

## Cleanup

```bash
./cleanup.sh
```

## Blog post

A related blog post is published on medium:

https://blog.kubernauts.io/simplicity-matters-kubernetes-1-16-fffbf7e84944


