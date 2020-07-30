#!/bin/bash

echo "[TASK] Reset cluster if exist"
kubeadm reset -f >/dev/null

# Initialize Kubernetes
echo "[TASK] Initialize Kubernetes Cluster"
kubeadm init --apiserver-advertise-address=192.168.100.10 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log 2>/dev/null

# Copy Kube admin config
echo "[TASK] Copy kube admin config to Vagrant user .kube directory"
mkdir $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config

# Deploy Calico network
echo "[TASK] Deploy Calico network"
kubectl create -f https://docs.projectcalico.org/v3.11/manifests/calico.yaml 2>/dev/null

# Generate Cluster join command
echo "[TASK] Generate and save cluster join command to /joincluster.sh"
kubeadm token create --print-join-command > /joincluster.sh

echo "[TASK] Restart and enable kubelet"
systemctl enable kubelet
service kubelet restart
