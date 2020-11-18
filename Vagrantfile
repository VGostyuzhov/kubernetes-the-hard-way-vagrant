# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.box_check_update = false
  config.vm.provider "virtualbox" do |vb|
#    vb.cpus = 1
#    vb.memory = 768
  end

  # must be at the top
  config.vm.define "lb-0" do |c|
    c.vm.hostname = "lb-0"
    c.vm.network "private_network", ip: "192.168.100.40"

    c.vm.provision :shell, :path => "scripts/setup-haproxy.sh"

    c.vm.provider "virtualbox" do |vb|
      vb.name = "lb-0"
      vb.memory = "256"
    end
  end

  (0..1).each do |i|
    config.vm.define "controller-#{i}" do |node|
      node.vm.hostname = "controller-#{i}"
      node.vm.network "private_network", ip: "192.168.100.1#{i}"
      node.vm.provision :hosts, :sync_hosts => true
      node.vm.provider "virtualbox" do |vb|
        vb.name = "controller-#{i}"
        vb.cpus = 1
        vb.memory = 1024
      end
      # Copy certificates
      node.vm.provision "file", source: "pki/ca/ca.pem", destination: "/home/vagrant/ca.pem"
      node.vm.provision "file", source: "pki/ca/ca-key.pem", destination: "/home/vagrant/ca-key.pem"
      node.vm.provision "file", source: "pki/api-server/kubernetes-key.pem", destination: "/home/vagrant/kubernetes-key.pem"
      node.vm.provision "file", source: "pki/api-server/kubernetes.pem", destination: "/home/vagrant/kubernetes.pem"
      # Copy kubeconfigs
      node.vm.provision "file", source: "configs/admin.kubeconfig", destination: "/home/vagrant/admin.kubeconfig"
      node.vm.provision "file", source: "configs/kube-controller-manager.kubeconfig", destination: "/home/vagrant/kube-controller-manager.kubeconfig"
      node.vm.provision "file", source: "configs/kube-scheduler.kubeconfig", destination: "/home/vagrant/kube-scheduler.kubeconfig"
      # Copy Encryption config
      node.vm.provision "file", source: "configs/encryption-config.yaml", destination: "/home/vagrant/encryption-config.yaml"    
      # Copy etcd setup script
      node.vm.provision "file", source: "scripts/setup-etcd-controller-#{i}.sh", destination: "/home/vagrant/setup-etcd-controller-#{i}.sh"      
      # Provisioning script
      node.vm.provision "shell", path: "scripts/heartbeat.sh"
    end
  end

  (0..1).each do |i|
    config.vm.define "worker-#{i}" do |node|
      node.vm.hostname = "worker-#{i}"
      node.vm.network "private_network", ip: "192.168.100.2#{i}"
      node.vm.provision :hosts, :sync_hosts => true
      node.vm.provider "virtualbox" do |vb|
        vb.name = "worker-#{i}"
        vb.cpus = 1
        vb.memory = 512
      end
      # Copy certificates
      node.vm.provision "file", source: "pki/ca/ca.pem", destination: "/home/vagrant/ca.pem"
      node.vm.provision "file", source: "pki/kubelet/worker-#{i}-key.pem", destination: "/home/vagrant/kubelet-key.pem"
      node.vm.provision "file", source: "pki/kubelet/worker-#{i}.pem", destination: "/home/vagrant/kubelet.pem"
      # Copy kubeconfigs
      node.vm.provision "file", source: "configs/worker-#{i}.kubeconfig", destination: "/home/vagrant/worker-#{i}.kubeconfig"
      node.vm.provision "file", source: "configs/kube-proxy.kubeconfig", destination: "/home/vagrant/kube-proxy.kubeconfig"
      # Provisioning script
      node.vm.provision "shell", path: "scripts/worker-provision.sh"
    end
  end
end

