# Vagrant pour Kubernetes

## Installation

Activer les plugins :
    
    $ vagrant plugin install vagrant-env
    $ vagrant plugin install vagrant-vbguest

## Ajouter un serveur NFS

Ajouter le code suivant dans VagrantFile :

    # Kubernetes NFS server
    config.vm.define "kubnfs" do |kubnfs|
        kubnfs.vm.box = "centos/7"
        kubnfs.vm.hostname = "kubnfs.example.com"
        kubnfs.vm.network "private_network", ip: "192.168.100.20"
        kubnfs.vm.provider "virtualbox" do |v|
            v.name = "kubnfs"
            v.memory = 1024
            v.cpus = 1
            v.customize ["modifyvm", :id, "--audio", "none"]
        end
        config.vm.provision "shell", inline: <<-SHELL
            sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
            systemctl reload sshd
        SHELL
        kubnfs.vm.provision "shell", path: "bootstrap_kubnfs.sh"
    end

# Autocomplétion bash

Ajouter la ligne suivante dans le fichier `/root/.bashrc`:

    source <(kubectl completion bash)

Relancer la session `root`
