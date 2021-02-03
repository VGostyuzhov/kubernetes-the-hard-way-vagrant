#!/bin/bash

function echo_bold {
  tput bold; echo $1; tput sgr0
}

dir="$(dirname "${BASH_SOURCE[0]}")/"
echo $dir

echo_bold "Generating certificates for admin user"
$dir/gen_certs_admin.sh

echo_bold "Generating certificates for Kube API server"
$dir/gen_certs_apiserver.sh

echo_bold "Generating certificates for Kube Controller Manager"
$dir/gen_certs_kube_controller_manager.sh

echo_bold "Generating certificates for Kube Proxy"
$dir/gen_certs_kube_proxy.sh

echo_bold "Generating certificates for Kube Scheduler"
$dir/gen_certs_kube_scheduler.sh

echo_bold "Generating certificates for Kubelet"
$dir/gen_certs_kubelet.sh

echo_bold "Generating certificates for Service Account"
$dir/gen_certs_service_account.sh
