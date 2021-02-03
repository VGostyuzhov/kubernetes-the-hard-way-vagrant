vagrant:
	vagrant plugin install vagrant-hosts

cfssl:
	go get -u github.com/cloudflare/cfssl/cmd/cfssl

gen-certs:
	./scripts/generate_certs.sh

gen-configs:
	./scripts/generate_configs.sh