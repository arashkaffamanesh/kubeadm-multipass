# Multi-Node Kubernetes 1.16 with kubeadm on multipass

These simple scripts deploy a multi-node Kubernetes 1.16 with kuneadm on multipass VMs on your local machine.

## Prerequsists

You need kubectl and multipass installed on your laptop.

## Installation

Deploy the master node with:

```bash
./deploy.sh
```

and take a note of the `kubeadm join` command.

Deploy the worker nodes with:

```bash
./2-deploy-kubeadm-nodes.sh
```

And follow the instructions from the output to join your worker nodes.

That's it :-)

## Troubleshooting

Note: we're using Calico here, if 192.178.0.0/16 is already in use within your network you must select a different pod network CIDR, replacing 192.178.0.0/16 in the kubeadm init command in `./1-deploy-kubeadm-matser.sh` script as well as in the `calico.yaml` file provided in this repo.

## Cleanup

```bash
./cleanup.sh
```



