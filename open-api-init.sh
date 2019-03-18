#!/usr/bin/env bash

curl -O https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz
tar zxvf openjdk-11.0.1_linux-x64_bin.tar.gz
mv jdk-11.0.1 /usr/local/
echo 'export JAVA_HOME=/usr/local/jdk-11.0.1;export PATH=$PATH:$JAVA_HOME/bin' | sudo tee /etc/profile.d/jdk11.sh
source /etc/profile.d/jdk11.sh

ln -sf /usr/local/jdk-11.0.1/bin/java /sbin/java

aws s3 cp s3://repo.bsm.pub/cloud-formation-init/open-api.env /etc/default/open-api.env
aws s3 cp s3://repo.bsm.pub/cloud-formation-init/open-api.service /etc/systemd/system/open-api.service
aws s3 cp s3://repo.bsm.pub/cloud-formation-init/open-api.conf /etc/rsyslog.d/open-api.conf
aws s3 cp s3://repo.bsm.pub/cloud-formation-init/logback-spring.xml /opt/open-api/logback-spring.xml
aws s3 cp s3://repo.bsm.pub/cloud-formation-init/bsm-secrets.json /opt/open-api/bsm-secrets.json

chmod -R 500 /opt/open-api
mkdir /opt/open-api/logs

chown -R ec2-user:ec2-user /opt/open-api

VAULT_VERSION="1.0.3"
_VAULT_TOKEN="00000000-0000-0000-0000-000000000000"
_VAULT_ADDR="http://127.0.0.1:8200"

export VAULT_ADDR=${_VAULT_ADDR}
export VAULT_TOKEN=${_VAULT_TOKEN}

echo "export VAULT_ADDR=${_VAULT_ADDR}; export VAULT_TOKEN=${_VAULT_TOKEN}" > /etc/profile.d/vault.sh
chmod +x /etc/profile.d/vault.sh

wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
unzip vault_${VAULT_VERSION}_linux_amd64.zip
chown root:root vault
mv vault /usr/local/bin
vault -autocomplete-install
complete -C /usr/local/bin/vault vault
useradd --system --home /etc/vault.d --shell /bin/false vault
mkdir /etc/vault.d
chown -R vault:vault /etc/vault.d

aws s3 cp s3://repo.bsm.pub/cloud-formation-init/vault.service /etc/systemd/system/vault.service

systemctl enable vault
systemctl start vault

sleep 10
vault kv put secret/open-api @/opt/open-api/bsm-secrets.json

systemctl daemon-reload
systemctl enable open-api
systemctl start open-api
