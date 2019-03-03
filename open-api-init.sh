#!/usr/bin/env bash

curl -O https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz
tar zxvf openjdk-11.0.1_linux-x64_bin.tar.gz
mv jdk-11.0.1 /usr/local/
echo 'export JAVA_HOME=/usr/local/jdk-11.0.1;export PATH=$PATH:$JAVA_HOME/bin' | sudo tee /etc/profile.d/jdk11.sh
source /etc/profile.d/jdk11.sh

chown ec2-user:ec2-user /home/ec2-user/open-api.jar
chmod 500 /home/ec2-user/open-api.jar

ln -sf /home/ec2-user/open-api.jar /etc/init.d/open-api
ln -sf /usr/local/jdk-11.0.1/bin/java /sbin/java

service open-api start

