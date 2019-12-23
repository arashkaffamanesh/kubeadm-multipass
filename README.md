# Multi-Node Kubernetes 1.17 with kubeadm on local multipass cloud with Docker, Containerd or CRI-O and Rancher Server on top

These simple scripts deploy a multi-node Kubernetes 1.16.2 with kubeadm on multipass VMs with Containerd, Docker or CRI-O on your local machine in about 6 minutes, depending on your internet speed.

## About Multipass

https://multipass.run/

## Prerequsists

You need kubectl and multipass installed on your laptop.

### Install multipass (on MacOS Catalina or Linux)

Multipass v0.9 has been released for MacOS Catalina, please download the latest release:

https://github.com/CanonicalLtd/multipass/releases


```bash
wget https://github.com/CanonicalLtd/multipass/releases/download/v0.9.0/multipass-0.9.0+mac-Darwin.pkg
sudo installer -target / -verbose -pkg multipass-0.9.0+mac-Darwin.pkg
snap install multipass --channel beta/0.9 --classic
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
master    Ready    master   8m55s   v1.17.0
worker1   Ready    node     3m45s   v1.17.0
worker2   Ready    node     3m24s   v1.17.0
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

You can deploy Rancher Server on top of your kubeadm cluster with:

```bash
./4-deploy-rancher-on-kubeadm.sh
# a browser tab should pop up to Rancher Server UI
```

## Traefik with mkcert to create a local certificate authority with wildcard certificate

```bash
brew install mkcert
mkcert --install
# provision a wildcard certificate for our new local domain
mkcert '*.k8s.local'
# This will create two files: _wildcard.k8s.local-key.pem and _wildcard.k8s.local.pem.
kubectl -n kube-system create secret tls traefik-tls-cert --key=_wildcard.k8s.local-key.pem --cert=_wildcard.k8s.local.pem
```

### Setting up Traefik

```bash
kubectl apply -f configmap.yml
kubectl create -f traefik.yaml
kubectl apply -f rbac.yml
get pods -n kube-system | grep traefik
# you should see a line that looks like the following
traefik-ingress-controller-68c5fbccbd-5kjvw   1/1     Running
```

### Testing with whoami

```bash
kubectl create -f whoami-deployment.yml
# create a host entry in /etc/hosts like this to the IP of the traefik ingress controller svc
# 192.168.64.23 whoami.k8s.local 
curl https://whoami.k8s.local
# or
open https://whoami.k8s.local
# it should work
```

With that you can eypose services over a valid HTTPS connection with your private local CA!

### Exercise 

Change the whoami service type to LoadBalancer and see what happens :-)

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

## Related resources

https://medium.com/localz-engineering/kubernetes-traefik-locally-with-a-wildcard-certificate-e15219e5255d




