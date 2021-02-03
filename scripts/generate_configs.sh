#!/bin/bash

function echo_bold {
  tput bold; echo $1; tput sgr0
}

dir="$(dirname "${BASH_SOURCE[0]}")"
echo $dir

echo_bold "Generating Admin kubeconfig"
$dir/gen_config_admin.sh
echo_bold "Generating Kube Controller Manager kubeconfig"
$dir/gen_config_kube_controller_manager.sh
echo_bold "Generating Kube Scheduler kubeconfig"
$dir/gen_config_kube_scheduler.sh
echo_bold "Generating Kube Proxy kubeconfig"
$dir/gen_config_kube_proxy.sh
echo_bold "Generating Kube Workers kubeconfig"
$dir/gen_config_workers.sh
echo_bold "Generating Encryption config"
$dir/gen_config_encryption.sh
