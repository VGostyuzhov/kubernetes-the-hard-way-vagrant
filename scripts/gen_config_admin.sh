#!/bin/bash

CONFIG_FILE=../configs/admin.kubeconfig
PKI_FOLDER=../pki
{
  
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=$PKI_FOLDER/ca/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=$CONFIG_FILE

  kubectl config set-credentials admin \
    --client-certificate=$PKI_FOLDER/admin/admin.pem \
    --client-key=$PKI_FOLDER/admin/admin-key.pem \
    --embed-certs=true \
    --kubeconfig=$CONFIG_FILE

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=$CONFIG_FILE

  kubectl config use-context default --kubeconfig=$CONFIG_FILE
}
