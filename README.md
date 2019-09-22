# Multi-Node Kubernetes 1.16 with kubeadm on multipass

These simple scripts deploy a multi-node Kubernetes 1.16 with kubeadm on multipass VMs on your local machine.

## Prerequsists

You need kubectl and multipass installed on your laptop.

## Installation

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

That's it :-)

You should get something similar to this:

```bash
NAME      STATUS   ROLES    AGE     VERSION
master    Ready    master   6m24s   v1.16.0
worker1   Ready    node     42s     v1.16.0
worker2   Ready    node     32s     v1.16.0
############################################################################
Enjoy and learn to love learning :-)
Total runtime in minutes was: 09:12
############################################################################
```


## Troubleshooting

Note: we're using Calico here, if 192.178.0.0/16 is already in use within your network you must select a different pod network CIDR, replacing 192.178.0.0/16 in the kubeadm init command in `./1-deploy-kubeadm-matser.sh` script as well as in the `calico.yaml` file provided in this repo.

## Cleanup

```bash
./cleanup.sh
```

## Blog post

A related blog post is published on medium:

https://blog.kubernauts.io/simplicity-matters-kubernetes-1-16-fffbf7e84944


