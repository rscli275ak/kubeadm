#!/bin/bash

echo "[TASK 0] Reset cluster if exist"
kubeadm reset -f >/dev/null

# Join worker nodes to the Kubernetes cluster
echo "[TASK 1] Join node to Kubernetes Cluster"
yum install -q -y sshpass >/dev/null 2>&1
sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kubmaster.example.com:/joincluster.sh /joincluster.sh 2>/dev/null
bash /joincluster.sh >/dev/null 2>&1

echo "[TASK 2] Restart and enable kubelet"
systemctl enable kubelet
service kubelet restart