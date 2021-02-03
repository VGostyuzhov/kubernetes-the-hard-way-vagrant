#!/bin/bash

dir="$(dirname "${BASH_SOURCE[0]}")/.."
pushd "${dir}/pki/kubelet" || exit
trap 'popd' EXIT

HOSTNAME_FIRST="worker-0"
INTERNAL_IP_FIRST="192.168.100.20"
cfssl gencert \
  -ca=../ca/ca.pem \
  -ca-key=../ca/ca-key.pem \
  -config=../ca/ca-config.json \
  -hostname="${HOSTNAME_FIRST}","${INTERNAL_IP_FIRST}" \
  -profile=kubernetes \
  "${HOSTNAME_FIRST}"-csr.json | cfssljson -bare "${HOSTNAME_FIRST}"


HOSTNAME_SECOND="worker-1"
INTERNAL_IP_SECOND="192.168.100.20"
cfssl gencert \
  -ca=../ca/ca.pem \
  -ca-key=../ca/ca-key.pem \
  -config=../ca/ca-config.json \
  -hostname="${HOSTNAME_SECOND}","${INTERNAL_IP_SECOND}" \
  -profile=kubernetes \
  "${HOSTNAME_SECOND}"-csr.json | cfssljson -bare "${HOSTNAME_SECOND}"  
