#!/bin/bash

KUBERNETES_PUBLIC_ADDRESS=192.168.100.40
CONFIG_FILE=../configs/kube-proxy.kubeconfig
PKI_FOLDER=../pki

{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=$PKI_FOLDER/ca/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=$CONFIG_FILE

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=$PKI_FOLDER/kube-proxy/kube-proxy.pem \
    --client-key=$PKI_FOLDER/kube-proxy/kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=$CONFIG_FILE

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=$CONFIG_FILE

  kubectl config use-context default --kubeconfig=$CONFIG_FILE
}
