#!/bin/bash
OS="xUbuntu_20.04"
K8S_VERSION="v1.18.6"
CRIO_VERSION="1.18"
CNI_VERSION="v0.8.6"

function echo_bold {
  tput bold; echo $1; tput sgr0
}

echo_bold "Set POD_CIDR based on hostname"
if   [ "$HOSTNAME" == "worker-0" ]
then
  POD_CIDR=10.0.20.0/24
elif [ "$HOSTNAME" == "worker-1" ]
then
  POD_CIDR=10.0.21.0/24
fi
echo_bold $POD_CIDR

echo_bold "Install the OS dependencies:"
{
  sudo apt-get update
  sudo apt-get -y install socat conntrack ipset
}

echo_bold "Disable Swap"
sudo swapoff -a

# ===== CNI =====
echo_bold " Install CNI Networking"
wget -q --show-progress --https-only --timestamping https://github.com/containernetworking/plugins/releases/download/$CNI_VERSION/cni-plugins-linux-amd64-$CNI_VERSION.tgz
sudo mkdir -p /opt/cni/bin
sudo tar --extract --file cni-plugins-linux-amd64-$CNI_VERSION.tgz -C /opt/cni/bin/

echo_bold " Configure CNI Networking"
sudo mkdir -p /etc/cni/net.d 
sed -e "s;%POD_CIDR%;$POD_CIDR;g" /vagrant/configs/10-bridge.conf.tmpl | sudo tee /etc/cni/net.d/10-bridge.conf

echo_bold " Create the loopback network configuration file"
sudo cp /vagrant/configs/99-loopback.conf /etc/cni/net.d/99-loopback.conf 


# ===== CRI-O =====
echo_bold "Download and install crio binaries"

sudo cp /vagrant/configs/crio.conf /etc/modules-load.d/crio.conf
sudo modprobe overlay
sudo modprobe br_netfilter

sudo cp /vagrant/configs/99-kubernetes-cri.conf /etc/sysctl.d/99-kubernetes-cri.conf
sudo sysctl --system

echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /" | sudo tee  /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o.list
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -
sudo apt update
sudo apt install -y cri-o cri-o-runc


# ===== Kubernetes =====
echo_bold "Download kubelet, kube-proxy and kubectl binaries"
wget -q --show-progress --https-only --timestamping \
  https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubelet

echo_bold "Create the installation directories"
sudo mkdir -p \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes

echo_bold "Install the worker binaries"
sudo chmod +x kubectl kube-proxy kubelet
sudo mv kubectl kube-proxy kubelet /usr/local/bin/

echo_bold "Copy kubelet certificates"
sudo cp /vagrant/pki/ca/ca.pem /var/lib/kubernetes/
sudo cp "/vagrant/pki/kubelet/$(hostname).pem" "/vagrant/pki/kubelet/$(hostname)-key.pem" /var/lib/kubelet

echo_bold "Copy kubelet kubeconfigs"
sudo cp "/vagrant/configs/$(hostname).kubeconfig" /var/lib/kubelet/kubeconfig
sed -e "s;%POD_CIDR%;$POD_CIDR;g" -e "s;%HOSTNAME%;$HOSTNAME;g"  /vagrant/configs/kubelet-config.yaml.tmpl | sudo tee /var/lib/kubelet/kubelet-config.yaml
sudo cp /vagrant/configs/kubelet.service /etc/systemd/system/kubelet.service

echo_bold "Configure the Kubernetes Proxy"
sudo cp /vagrant/configs/kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig
sudo cp /vagrant/configs/kube-proxy-config.yaml /var/lib/kube-proxy/kube-proxy-config.yaml
sudo cp /vagrant/configs/kube-proxy.service /etc/systemd/system/kube-proxy.service

echo_bold "Enable and start daemons"
sudo systemctl daemon-reload
sudo systemctl enable crio kubelet kube-proxy
sudo systemctl start crio kubelet kube-proxy