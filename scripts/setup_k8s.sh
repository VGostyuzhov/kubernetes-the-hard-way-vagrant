#!/bin/bash

function echo_bold {
  tput bold; echo $1; tput sgr0
}

echo_bold "Create the Kubernetes configuration directory"
sudo mkdir -p /etc/kubernetes/config

echo_bold "Download the official Kubernetes release binaries"
wget -q --show-progress --https-only --timestamping \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.6/bin/linux/amd64/kube-apiserver" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.6/bin/linux/amd64/kube-controller-manager" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.6/bin/linux/amd64/kube-scheduler" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.6/bin/linux/amd64/kubectl"

echo_bold "Install the Kubernetes binaries: kube-apiserver kube-controller-manager kube-scheduler kubectl"
chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
sudo cp kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/

echo_bold "Create dir /var/lib/kubernetes/"
sudo mkdir -p /var/lib/kubernetes/

echo_bold "Configure the Kubernetes API Server"

echo_bold "Copy certificates and encryption config to /var/lib/kubernetes/"
sudo cp \
  /vagrant/pki/ca/ca.pem \
  /vagrant/pki/ca/ca-key.pem \
  /vagrant/pki/api-server/kubernetes-key.pem \
  /vagrant/pki/api-server/kubernetes.pem \
  /vagrant/pki/service-account/service-account-key.pem \
  /vagrant/pki/service-account/service-account.pem \
  /vagrant/configs/encryption-config.yaml /var/lib/kubernetes/

echo_bold "kube-apiserver.service systemd unit file"
sudo cp /vagrant/configs/"$(hostname -s)"-kube-apiserver.service /etc/systemd/system/kube-apiserver.service

echo_bold "kube-controller-manager.service systemd unit file"
sudo cp /vagrant/configs/kube-controller-manager.service /etc/systemd/system/kube-controller-manager.service

echo_bold "Copy the kube-controller-manager.kubeconfig into place:"
sudo cp /vagrant/configs/kube-controller-manager.kubeconfig /var/lib/kubernetes/

echo_bold "Copy the kube-scheduler.kubeconfig into place:"
sudo cp /vagrant/configs/kube-scheduler.kubeconfig /var/lib/kubernetes/

echo_bold "Create the kube-scheduler.yaml configuration file"
sudo cp /vagrant/configs/kube-scheduler.yaml /etc/kubernetes/config/kube-scheduler.yaml

echo_bold "Create the kube-scheduler.service systemd unit file:"
sudo cp /vagrant/configs/kube-scheduler.service /etc/systemd/system/kube-scheduler.service

echo_bold "Start the Controller Services"
sudo systemctl daemon-reload
sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler
sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler

echo_bold "Create the system:kube-apiserver-to-kubelet ClusterRole with permissions to access the Kubelet API"
echo_bold "Bind the system:kube-apiserver-to-kubelet ClusterRole to the kubernetes user:"
kubectl create --kubeconfig /vagrant/configs/admin.kubeconfig -f /vagrant/configs/kube-apiserver-to-kubelet.yaml
