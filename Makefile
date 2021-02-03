vagrant:
	vagrant plugin install vagrant-hosts

cfssl:
	go get -u github.com/cloudflare/cfssl/cmd/cfssl

gen-certs:

gen-configs: