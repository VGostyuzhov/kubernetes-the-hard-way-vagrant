#!/bin/bash
K8S_VERSION=v1.18.6
CRI_VERSION=v1.18.0
RUNC_VERSION=v1.0.0-rc91
CONTAINERD_VERSION=1.3.6
CNI_VERSION=v0.8.6
# Install the OS dependencies:
{
  sudo apt-get update
  sudo apt-get -y install socat conntrack ipset
}

# Disable Swap
sudo swapoff -a

# Download and Install Worker Binaries
wget -q --show-progress --https-only --timestamping \
  https://github.com/kubernetes-sigs/cri-tools/releases/download/$CRI_VERSION/crictl-$CRI_VERSION-linux-amd64.tar.gz \
  https://github.com/opencontainers/runc/releases/download/$RUNC_VERSION/runc.amd64 \
  https://github.com/containernetworking/plugins/releases/download/$CNI_VERSION/cni-plugins-linux-amd64-$CNI_VERSION.tgz \
  https://github.com/containerd/containerd/releases/download/v$CONTAINERD_VERSION/containerd-$CONTAINERD_VERSION-linux-amd64.tar.gz \
  https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubelet

# Create the installation directories
sudo mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes

# Install the worker binaries
{
  mkdir containerd
  tar -xvf crictl-$CRI_VERSION-linux-amd64.tar.gz
  tar -xvf containerd-$CONTAINERD_VERSION-linux-amd64.tar.gz -C containerd
  sudo tar -xvf cni-plugins-linux-amd64-$CNI_VERSION.tgz -C /opt/cni/bin/
  sudo mv runc.amd64 runc
  chmod +x crictl kubectl kube-proxy kubelet runc
  sudo mv crictl kubectl kube-proxy kubelet runc /usr/local/bin/
  sudo mv containerd/bin/* /bin/
}

# Configure CNI Networking
POD_CIDR=
