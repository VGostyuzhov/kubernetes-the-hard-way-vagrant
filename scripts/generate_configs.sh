#!/bin/bash

function echo_bold {
  tput bold; echo $1; tput sgr0
}

echo_bold "Generating Admin kubeconfig"
./gen_configs_admin.sh
echo_bold "Generating Kube Controller Manager kubeconfig"
./gen_configs_kube_controller_manager.sh
echo_bold "Generating Kube Scheduler kubeconfig"
./gen_configs_kube_scheduler.sh
echo_bold "Generating Kube Proxy kubeconfig"
./gen_configs_kube_proxy.sh
echo_bold "Generating Kube Workers kubeconfig"
./gen_configs_workers.sh
echo_bold "Generating Encryption config"
./gen_encryption_config.sh
