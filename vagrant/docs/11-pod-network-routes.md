# Provisioning Pod Network Routes

## Flannel

Use `flannel` to solve communication problems between pods.

```
wget -q --show-progress --https-only --timestamping \
	"https://raw.githubusercontent.com/coreos/flannel/v0.12.0/Documentation/kube-flannel.yml"
```

Add `--iface-regex=192.168.100.` at line `192` in the command args of the amd64 container image.

Resultant `kube-flannel.yml` should now contains:

```
      containers:
      - name: kube-flannel
        image: quay.io/coreos/flannel:v0.12.0-amd64
        command:
        - /opt/bin/flanneld
        args:
        - --ip-masq
        - --kube-subnet-mgr
        - --iface-regex=192.168.100.

```

```
kubectl apply -f kube-flannel.yml
```

> output

```
clusterrole "flannel" created
clusterrolebinding "flannel" created
serviceaccount "flannel" created
configmap "kube-flannel-cfg" created
daemonset "kube-flannel-ds" created
```

### Verify
```
kubectl -n kube-system get pods
```

> output

```
NAME                    READY     STATUS    RESTARTS   AGE
kube-flannel-ds-8p2pd   1/1       Running   0          1m
kube-flannel-ds-9mxnc   1/1       Running   0          1m
kube-flannel-ds-ldfq6   1/1       Running   0          1m
```

同时 worker 状态也会更新为`Ready`。

```
kubectl get nodes
```

> output

```
NAME       STATUS    ROLES     AGE      VERSION
worker-0   Ready     <none>    3m       v1.8.0
worker-1   Ready     <none>    3m       v1.8.0
worker-2   Ready     <none>    3m       v1.8.0
```

Next: [Deploying the DNS Cluster Add-on](12-dns-addon.md)
