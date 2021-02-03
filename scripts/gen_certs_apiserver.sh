#!/bin/bash

dir="$(dirname "${BASH_SOURCE[0]}")/.."

pushd "${dir}/pki/api-server" || exit
trap 'popd' EXIT

cfssl gencert \
  -ca=../ca/ca.pem \
  -ca-key=../ca/ca-key.pem \
  -config=../ca/ca-config.json \
  -hostname=10.32.0.1,192.168.100.10,192.168.100.11,"${KUBERNETES_PUBLIC_ADDRESS}",127.0.0.1,kubernetes.default \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
