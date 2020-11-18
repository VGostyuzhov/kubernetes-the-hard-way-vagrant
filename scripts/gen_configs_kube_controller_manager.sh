#!/bin/bash

CONFIG_FILE=../configs/kube-controller-manager.kubeconfig
PKI_FOLDER=../pki

{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=$PKI_FOLDER/ca/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=$CONFIG_FILE

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=$PKI_FOLDER/kube-controller-manager/kube-controller-manager.pem \
    --client-key=$PKI_FOLDER/kube-controller-manager/kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=$CONFIG_FILE

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=$CONFIG_FILE

  kubectl config use-context default --kubeconfig=$CONFIG_FILE
}
