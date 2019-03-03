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

chmod -R 500 /opt/open-api
mkdir /opt/open-api/logs

chown -R ec2-user:ec2-user /opt/open-api

systemctl daemon-reload
systemctl enable open-api
systemctl start open-api
