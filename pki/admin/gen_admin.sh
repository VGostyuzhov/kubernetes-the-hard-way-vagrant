cfssl gencert \
  -ca=../ca/ca.pem \
  -ca-key=../ca/ca-key.pem \
  -config=../ca/ca-config.json \
  -profile=kubernetes \
  admin-csr.json  | cfssljson -bare  admin
