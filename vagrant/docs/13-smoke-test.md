# Smoke Test

In this lab you will complete a series of tasks to ensure your Kubernetes cluster is functioning correctly.

## Data Encryption

In this section you will verify the ability to [encrypt secret data at rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#verifying-that-data-is-encrypted).

Create a generic secret:

```
kubectl create secret generic kubernetes-the-hard-way \
  --from-literal="mykey=mydata"
```

Print a hexdump of the `kubernetes-the-hard-way` secret stored in etcd:

```
vagrant ssh controller-0 \
  --command "ETCDCTL_API=3 etcdctl get /registry/secrets/default/kubernetes-the-hard-way | hexdump -C"
```

> output

```
00000000  2f 72 65 67 69 73 74 72  79 2f 73 65 63 72 65 74  |/registry/secret|
00000010  73 2f 64 65 66 61 75 6c  74 2f 6b 75 62 65 72 6e  |s/default/kubern|
00000020  65 74 65 73 2d 74 68 65  2d 68 61 72 64 2d 77 61  |etes-the-hard-wa|
00000030  79 0a 6b 38 73 3a 65 6e  63 3a 61 65 73 63 62 63  |y.k8s:enc:aescbc|
00000040  3a 76 31 3a 6b 65 79 31  3a 53 95 c6 1b 6f 01 c0  |:v1:key1:S...o..|
00000050  36 ab c9 9e 2f 4c 14 3a  32 5d 2f 41 56 2b 4d df  |6.../L.:2]/AV+M.|
00000060  2c 17 d7 2a 3b d2 3e 69  a5 a6 7b 25 41 e9 48 5d  |,..*;.>i..{%A.H]|
00000070  b1 91 0f e8 32 e4 1c 9c  ed bd 6f 1a c9 94 d4 1c  |....2.....o.....|
00000080  07 66 09 5e a8 9a 4c 71  30 e2 fe 16 df 20 56 b4  |.f.^..Lq0.... V.|
00000090  8e 31 c1 f3 5c 7e 4d c2  11 5b 1c 54 b2 45 a0 97  |.1..\~M..[.T.E..|
000000a0  a3 43 fb 04 28 5a 84 be  5d 52 7b 68 07 56 bf f5  |.C..(Z..]R{h.V..|
000000b0  52 b6 5d 35 3b f2 ae 87  d6 e3 0b f3 a3 e8 08 8c  |R.]5;...........|
000000c0  0d db f4 6d f9 07 96 90  0d ce 5d 91 17 06 19 77  |...m......]....w|
000000d0  3b 91 43 ca 68 53 20 4d  cb 2a 62 00 45 62 d5 a6  |;.C.hS M.*b.Eb..|
000000e0  e3 89 9f 22 6c 0a cb 22  13 0a                    |..."l.."..|
000000ea
```

The etcd key should be prefixed with `k8s:enc:aescbc:v1:key1`, which indicates the `aescbc` provider was used to encrypt the data with the `key1` encryption key.

## Deployments

In this section you will verify the ability to create and manage [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).

Create a deployment for the [nginx](https://nginx.org/en/) web server:

```
kubectl run nginx --image=nginx
```

List the pod created by the `nginx` deployment:

```
kubectl get pods -l run=nginx
```

> output

```
NAME                       READY     STATUS    RESTARTS   AGE
nginx-7c87f569d-dmffs      1/1       Running   0          10m
```

### Port Forwarding

In this section you will verify the ability to access applications remotely using [port forwarding](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/).

Retrieve the full name of the `nginx` pod:

```
POD_NAME=$(kubectl get pods -l run=nginx -o jsonpath="{.items[0].metadata.name}")
```

Forward port `8080` on your local machine to port `80` of the `nginx` pod:

```
kubectl port-forward $POD_NAME 8080:80
```

> output

```
Forwarding from 127.0.0.1:8080 -> 80
```

In a new terminal make an HTTP request using the forwarding address:

```
curl --head http://127.0.0.1:8080
```

> output

```
HTTP/1.1 200 OK
Server: nginx/1.13.5
Date: Tue, 10 Oct 2017 02:45:29 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 08 Aug 2017 15:25:00 GMT
Connection: keep-alive
ETag: "5989d7cc-264"
Accept-Ranges: bytes
```

Switch back to the previous terminal and stop the port forwarding to the `nginx` pod:

```
Forwarding from 127.0.0.1:8080 -> 80
Handling connection for 8080
^C
```

### Logs

In this section you will verify the ability to [retrieve container logs](https://kubernetes.io/docs/concepts/cluster-administration/logging/).

Print the `nginx` pod logs:

```
kubectl logs $POD_NAME
```

> output

```
127.0.0.1 - - [10/Oct/2017:02:45:29 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.54.0" "-"
```

### Exec

In this section you will verify the ability to [execute commands in a container](https://kubernetes.io/docs/tasks/debug-application-cluster/get-shell-running-container/#running-individual-commands-in-a-container).

Print the nginx version by executing the `nginx -v` command in the `nginx` container:

```
kubectl exec -ti $POD_NAME -- nginx -v
```

> output

```
nginx version: nginx/1.13.5
```

## Services

In this section you will verify the ability to expose applications using a [Service](https://kubernetes.io/docs/concepts/services-networking/service/).

Expose the `nginx` deployment using a [NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport) service:

```
kubectl expose deployment nginx --port 80 --type NodePort
```

> The LoadBalancer service type can not be used because your cluster is not configured with [cloud provider integration](https://kubernetes.io/docs/getting-started-guides/scratch/#cloud-provider). Setting up cloud provider integration is out of scope for this tutorial.

Retrieve the node port assigned to the `nginx` service:

```
NODE_PORT=$(kubectl get svc nginx \
  --output=jsonpath='{range .spec.ports[0]}{.nodePort}')
```

Retrieve the external IP address of a worker instance:

```
EXTERNAL_IP=$(vagrant ssh worker-1 -- "ip -4 --oneline addr | grep -v secondary | grep -oP '(192\.168\.100\.[0-9]{1,3})(?=/)'")
```

Make an HTTP request using the external IP address and the `nginx` node port:

```
curl -I http://${EXTERNAL_IP}:${NODE_PORT}
```

> output

```
HTTP/1.1 200 OK
Server: nginx/1.13.5
Date: Tue, 10 Oct 2017 02:49:19 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 08 Aug 2017 15:25:00 GMT
Connection: keep-alive
ETag: "5989d7cc-264"
Accept-Ranges: bytes
```

Next: [Cleaning Up](14-cleanup.md)
