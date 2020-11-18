#!/bin/bash

KUBERNETES_PUBLIC_ADDRESS=192.168.100.40
PKI_FOLDER=../pki

for instance in worker-0 worker-1; do
  CONFIG_FILE=../configs/${instance}.kubeconfig
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=$PKI_FOLDER/ca/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=$CONFIG_FILE

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=$PKI_FOLDER/kubelet/${instance}.pem \
    --client-key=$PKI_FOLDER/kubelet/${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=$CONFIG_FILE

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${instance} \
    --kubeconfig=$CONFIG_FILE

  kubectl config use-context default --kubeconfig=$CONFIG_FILE
done
