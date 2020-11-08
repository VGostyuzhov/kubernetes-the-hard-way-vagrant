# Deploying the DNS Cluster Add-on

In this lab you will deploy the [DNS add-on](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/) which provides DNS based service discovery to applications running inside the Kubernetes cluster.

## The DNS Cluster Add-on

Deploy the `coredns` cluster add-on:

```
kubectl create -f kubectl apply -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns.yaml
```

> output

```
serviceaccount/coredns created
clusterrole.rbac.authorization.k8s.io/system:coredns created
clusterrolebinding.rbac.authorization.k8s.io/system:coredns created
configmap/coredns created
deployment.apps/coredns created
service/kube-dns created
```

List the pods created by the `kube-dns` deployment:

```
kubectl get pods -l k8s-app=kube-dns -n kube-system
```

> output

```
NAME                       READY   STATUS    RESTARTS   AGE
coredns-589fff4ffc-6k6h4   1/1     Running   0          22s
coredns-589fff4ffc-cqjsg   1/1     Running   0          22s
```

## Verification

Create a `busybox` deployment:

```
kubectl run busybox --image=busybox --command -- sleep 3600
```

List the pod created by the `busybox` deployment:

```
kubectl get pods -l run=busybox
```

> output

```
NAME                       READY     STATUS    RESTARTS   AGE
busybox-2125412808-mt2vb   1/1       Running   0          15s
```

Retrieve the full name of the `busybox` pod:

```
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
```

Execute a DNS lookup for the `kubernetes` service inside the `busybox` pod:

```
kubectl exec -ti $POD_NAME -- nslookup kubernetes
```

> output

```
Server:    10.32.0.10
Address 1: 10.32.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes
Address 1: 10.32.0.1 kubernetes.default.svc.cluster.local
```

## Upstream resolution

To enable upstream DNS resolution just download and modify the `coredns.yaml` int the `Corefile` section as follows:

```
  Corefile: |
    .:53 {
        errors
        health
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          upstream
          fallthrough in-addr.arpa ip6.arpa
        }
        forward . 8.8.8.8
        prometheus :9153
        cache 30
        loop
        reload
        loadbalance
    }
---
```

Next: [Smoke Test](13-smoke-test.md)
