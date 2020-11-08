# Bootstrapping the etcd Cluster

Kubernetes components are stateless and store cluster state in [etcd](https://github.com/coreos/etcd). In this lab you will bootstrap a three node etcd cluster and configure it for high availability and secure remote access.

## Download etcd Binaries

Download the official etcd release binaries from the [coreos/etcd](https://github.com/coreos/etcd) GitHub project:

```
ETCD_VERSION=3.4.7
wget -q --show-progress --https-only --timestamping \
  "https://github.com/coreos/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz"
```

## Prerequisites

The commands in this lab must be run on each controller instance: `controller-0`, `controller-1`, and `controller-2`. Login to each controller instance using the `vagrant ssh` command. Example:

```
vagrant ssh controller-0
```

## Bootstrapping an etcd Cluster Member

### Install etcd Binaries
Extract and install the `etcd` server and the `etcdctl` command line utility:

```
ETCD_VERSION=3.4.7
tar -xvf /vagrant/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz
```

```
sudo mv etcd-v${ETCD_VERSION}-linux-amd64/etcd* /usr/local/bin/
```

### Configure the etcd Server

```
sudo mkdir -p /etc/etcd /var/lib/etcd
```

```
(cd /vagrant/ && sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/)
```

The instance internal IP address will be used to serve client requests and communicate with etcd cluster peers. Retrieve the internal IP address for the current compute instance:

```
INTERNAL_IP=$(ip -4 --oneline addr | grep -v secondary | grep -oP '(192\.168\.100\.[0-9]{1,3})(?=/)')
```

Each etcd member must have a unique name within an etcd cluster. Set the etcd name to match the hostname of the current compute instance:

```
ETCD_NAME=$(hostname -s)
```

Create the `etcd.service` systemd unit file:

```
cat > etcd.service <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,http://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster controller-0=https://192.168.100.10:2380,controller-1=https://192.168.100.11:2380,controller-2=https://192.168.100.12:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### Start the etcd Server

```
sudo mv etcd.service /etc/systemd/system/
```

```
sudo systemctl daemon-reload
```

```
sudo systemctl enable etcd
```

```
sudo systemctl start etcd
```

> Remember to run the above commands on each controller node: `controller-0`, `controller-1`, and `controller-2`.

## Verification

List the etcd cluster members:

```
ETCDCTL_API=3 etcdctl member list
```

> output

```
1a82afa2247e7562, started, controller-2, https://192.168.100.12:2380, https://192.168.100.12:2379
9b08d67746040f15, started, controller-0, https://192.168.100.10:2380, https://192.168.100.10:2379
b9a27230d536d1e8, started, controller-1, https://192.168.100.11:2380, https://192.168.100.11:2379
```

Next: [Bootstrapping the Kubernetes Control Plane](08-bootstrapping-kubernetes-controllers.md)
