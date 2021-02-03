KUBERNETES_PUBLIC_ADDRESS=192.168.100.40

pki_dir="$(dirname "${BASH_SOURCE[0]}")/../pki"
echo $pki_dir

  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority="${pki_dir}/ca/ca.pem" \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443

  kubectl config set-credentials admin \
    --client-certificate="${pki_dir}/admin/admin.pem" \
    --client-key="${pki_dir}/admin/admin-key.pem"

  kubectl config set-context kubernetes-the-hard-way \
    --cluster=kubernetes-the-hard-way \
    --user=admin

  kubectl config use-context kubernetes-the-hard-way
