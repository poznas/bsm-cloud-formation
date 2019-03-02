#!/usr/bin/env bash
curl -O https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz
tar zxvf openjdk-11.0.1_linux-x64_bin.tar.gz
sudo mv jdk-11.0.1 /usr/local/
echo 'export JAVA_HOME=/usr/local/jdk-11.0.1;export PATH=$PATH:$JAVA_HOME/bin' | sudo tee /etc/profile.d/jdk11.sh
source /etc/profile.d/jdk11.sh
aws s3 cp s3://repo.bsm.pub/release/com/bsm/application/0.0.22/application-0.0.22.jar /home/ec2-user/application-0.0.22.jar
nohup java -jar application-0.0.22.jar
