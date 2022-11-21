#!/bin/bash
cd
mkdir mirror
wget https://developers.redhat.com/content-gateway/rest/mirror/pub/openshift-v4/clients/mirror-registry/latest/mirror-registry.tar.gz
ssh-keygen
ssh-copy-id quayhostname
sudo ./mirror-registry install --initUser quay --initPassword quayquay --quayHostname quayhostname --sslCert cert.pem --sslKey privkey.pem
sudo firewall-cmd --add-port=8443/tcp --zone=public --permanent
sudo firewall-cmd --reload