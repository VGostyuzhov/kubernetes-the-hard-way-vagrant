#!/bin/bash

CONFIG_FILE=../configs/kube-scheduler.kubeconfig
PKI_FOLDER=../pki

{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=$PKI_FOLDER/ca/ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=$CONFIG_FILE

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=$PKI_FOLDER/kube-scheduler/kube-scheduler.pem \
    --client-key=$PKI_FOLDER/kube-scheduler/kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=$CONFIG_FILE

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=$CONFIG_FILE

  kubectl config use-context default --kubeconfig=$CONFIG_FILE
}