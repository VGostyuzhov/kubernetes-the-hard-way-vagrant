#!/bin/bash

function echo_bold {
  tput bold; echo $1; tput sgr0
}

echo_bold "Generating certificates for admin user"
./gen_certs_admin.sh

echo_bold "Generating certificates for Kube API server"
./gen_certs_apiserver.sh

echo_bold "Generating certificates for Kube Controller Manager"
./gen_certs_kube_controller_manager.sh

echo_bold "Generating certificates for Kube Proxy"
./gen_certs_kube_proxy.sh

echo_bold "Generating certificates for Kube Scheduler"
./gen_certs_kube_scheduler.sh

echo_bold "Generating certificates for Kubelet"
./gen_certs_kubelet.sh

echo_bold "Generating certificates for Service Account"
./gen_certs_service_account.sh
