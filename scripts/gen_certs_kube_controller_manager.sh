#!/bin/bash

dir="$(dirname "${BASH_SOURCE[0]}")/.."

pushd "${dir}/pki/kube-controller-manager" || exit
trap 'popd' EXIT

cfssl gencert \
  -ca=../ca/ca.pem \
  -ca-key=../ca/ca-key.pem \
  -config=../ca/ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager
