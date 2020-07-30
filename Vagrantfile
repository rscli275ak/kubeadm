# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # Global configuration
  config.env.enable

  # Kubernetes Master Server
  config.vm.define "kubmaster" do |kmaster|
    kmaster.vm.box = "centos/7"
    kmaster.vm.hostname = "kubmaster.example.com"
    kmaster.vm.network "private_network", ip: "192.168.100.10"
    kmaster.vm.provider "virtualbox" do |v|
      v.name = "kubmaster"
      v.memory = 2048
      v.cpus = 2
      v.customize ["modifyvm", :id, "--audio", "none"]
    end
    config.vm.provision "shell", inline: <<-SHELL
      sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
      systemctl reload sshd
    SHELL
    config.vm.synced_folder ENV['HOST_DIR'], ENV['MASTER_DIR']
    kmaster.vm.provision "shell", path: "scripts/bootstrap_common.sh"
    kmaster.vm.provision "shell", path: "scripts/bootstrap_kubmaster.sh"
  end

  WorkerCount = 2

  # Kubernetes Worker Nodes
  (1..WorkerCount).each do |i|
    config.vm.define "kubworker#{i}" do |workernode|
      workernode.vm.box = "centos/7"
      workernode.vm.hostname = "kubworker#{i}.example.com"
      workernode.vm.network "private_network", ip: "192.168.100.1#{i}"
      workernode.vm.provider "virtualbox" do |v|
        v.name = "kubworker#{i}"
        v.memory = 2048
        v.cpus = 1
        v.customize ["modifyvm", :id, "--audio", "none"]
      end
      config.vm.provision "shell", inline: <<-SHELL
        sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
        systemctl reload sshd
      SHELL
      workernode.vm.provision "shell", path: "scripts/bootstrap_common.sh"
      workernode.vm.provision "shell", path: "scripts/bootstrap_kubworker.sh"
    end
  end

end