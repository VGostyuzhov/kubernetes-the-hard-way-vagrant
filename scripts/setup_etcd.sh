#!/bin/bash
ETCD_VERSION=v3.4.10

wget -q --show-progress --https-only --timestamping \
  "https://github.com/etcd-io/etcd/releases/download/$ETCD_VERSION/etcd-$ETCD_VERSION-linux-amd64.tar.gz"

# Extract and install the `etcd` server and the `etcdctl` command line utility:
tar -xvf etcd-$ETCD_VERSION-linux-amd64.tar.gz
sudo mv etcd-$ETCD_VERSION-linux-amd64/etcd* /usr/local/bin/

# Configure the etcd Server
sudo mkdir -p /etc/etcd /var/lib/etcd
sudo chmod 700 /var/lib/etcd
sudo cp \
  /vagrant/pki/ca/ca.pem \
  /vagrant/pki/api-server/kubernetes-key.pem \
  /vagrant/pki/api-server/kubernetes.pem \
  /etc/etcd/

# Create the `etcd.service` systemd unit file:
sudo cp /vagrant/configs/"$(hostname -s)"-etcd.service /etc/systemd/system/etcd.service

# Start the etcd Server
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd

