# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.box_check_update = false
  config.vm.provider "virtualbox" do |vb|
#    vb.cpus = 1
#    vb.memory = 768
  end

  # must be at the top
  config.vm.define "lb-0" do |c|
    c.vm.hostname = "lb-0"
    c.vm.network "private_network", ip: "192.168.100.40"

    c.vm.provision :shell, :path => "scripts/setup-routes.sh"
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

      node.vm.provision :shell, :path => "scripts/setup-routes.sh"

      node.vm.provision :hosts, :sync_hosts => true
      node.vm.provider "virtualbox" do |vb|
        vb.name = "controller-#{i}"
        vb.cpus = 1
        vb.memory = 1024
      end
    end
  end

  (0..1).each do |i|
    config.vm.define "worker-#{i}" do |node|
      node.vm.hostname = "worker-#{i}"
      node.vm.network "private_network", ip: "192.168.100.2#{i}"

      node.vm.provision :shell, :path => "scripts/setup-routes.sh"

      node.vm.provision :hosts, :sync_hosts => true
      node.vm.provider "virtualbox" do |vb|
        vb.name = "worker-#{i}"
        vb.cpus = 1
        vb.memory = 512
      end
    end
  end
end

