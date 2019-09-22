#!/bin/bash
multipass delete master worker1 worker2
multipass purge
rm kubeconfig.yaml