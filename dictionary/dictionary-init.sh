#!/usr/bin/env bash

curl -O https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz
tar zxvf openjdk-11.0.1_linux-x64_bin.tar.gz
mv jdk-11.0.1 /usr/local/
echo 'export JAVA_HOME=/usr/local/jdk-11.0.1;export PATH=$PATH:$JAVA_HOME/bin' | sudo tee /etc/profile.d/jdk11.sh
source /etc/profile.d/jdk11.sh

ln -sf /usr/local/jdk-11.0.1/bin/java /sbin/java

aws s3 cp s3://repo.bsm.pub/cloud-formation-init/dictionary/dictionary.env /etc/default/dictionary.env
aws s3 cp s3://repo.bsm.pub/cloud-formation-init/dictionary/dictionary.service /etc/systemd/system/dictionary.service
aws s3 cp s3://repo.bsm.pub/cloud-formation-init/dictionary/dictionary.conf /etc/rsyslog.d/dictionary.conf
aws s3 cp s3://repo.bsm.pub/cloud-formation-init/logback-spring.xml /opt/dictionary/logback-spring.xml

chmod -R 500 /opt/dictionary
mkdir /opt/dictionary/logs

chown -R ec2-user:ec2-user /opt/dictionary

systemctl daemon-reload
systemctl enable dictionary
systemctl start dictionary
