#!/bin/bash

dir="$(dirname "${BASH_SOURCE[0]}")/.."
pushd "${dir}/pki/kube-proxy" || exit
trap 'popd' EXIT

cfssl gencert \
  -ca=../ca/ca.pem \
  -ca-key=../ca/ca-key.pem \
  -config=../ca/ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy
