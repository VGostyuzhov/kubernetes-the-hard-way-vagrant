#!/bin/bash

dir="$(dirname "${BASH_SOURCE[0]}")/.."
pushd "${dir}/pki/service-account" || exit
trap 'popd' EXIT

cfssl gencert \
  -ca=../ca/ca.pem \
  -ca-key=../ca/ca-key.pem \
  -config=../ca/ca-config.json \
  -profile=kubernetes \
  service-account-csr.json  | cfssljson -bare  service-account