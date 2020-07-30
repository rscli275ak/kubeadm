#!/bin/bash

# Update hosts file
echo "[TASK 1] Update /etc/hosts file"
cat >>/etc/hosts <<EOF
192.168.100.10 kubmaster.example.com kubmaster
192.168.100.11 kubworker1.example.com kubworker1
192.168.100.12 kubworker2.example.com kubworker2
192.168.100.20 kubnfs.example.com kubnfs
EOF

# Installing utilities
echo "[TASK 2] Install Utilities"
yum install -y -q nfs-utils vim >/dev/null 2>&1

# Disable SELinux
echo "[TASK 3] Disable SELinux"
setenforce 0
sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

# Stop and disable firewalld
echo "[TASK 4] Stop and Disable firewalld"
systemctl disable firewalld >/dev/null 2>&1
systemctl stop firewalld

# Disable swap
echo "[TASK 5] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

# Enable ssh password authentication
echo "[TASK 6] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password [root:kubeadmin]
echo "[TASK 7] Set root password"
echo "kubeadmin" | passwd --stdin root >/dev/null 2>&1

echo "[TASK 8] Enable NFS shares"
if [ ! -d "/var/nfsshare" ];
then
    mkdir /var/nfsshare
fi
chmod -R 755 /var/nfsshare
systemctl enable rpcbind >/dev/null 2>&1
systemctl enable nfs-server >/dev/null 2>&1
systemctl enable nfs-lock >/dev/null 2>&1
systemctl enable nfs-idmap >/dev/null 2>&1
systemctl start rpcbind >/dev/null 2>&1
systemctl start nfs-server >/dev/null 2>&1
systemctl start nfs-lock >/dev/null 2>&1
systemctl start nfs-idmap >/dev/null 2>&1
echo "/var/nfsshare    192.168.100.0/16(rw,sync,no_root_squash,no_all_squash)" > /etc/exports
systemctl restart nfs-server >/dev/null 2>&1
#firewall-cmd --permanent --zone=public --add-service=nfs >/dev/null 2>&1
#firewall-cmd --permanent --zone=public --add-service=mountd >/dev/null 2>&1
#firewall-cmd --permanent --zone=public --add-service=rpc-bind >/dev/null 2>&1
#firewall-cmd --reload >/dev/null 2>&1

# Update vagrant user's bashrc file
echo "export TERM=xterm" >>/etc/bashrc
