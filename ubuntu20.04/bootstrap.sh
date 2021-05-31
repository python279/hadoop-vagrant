#!/usr/bin/env bash

cp /vagrant/hosts /etc/hosts
cp /vagrant/sources.list /etc/apt/

mkdir -p /root/.ssh
chmod 700 /root/.ssh
cp /vagrant/insecure_private_key /root/.ssh/id_rsa
cp /home/vagrant/.ssh/authorized_keys /root/.ssh/
cat /vagrant/authorized_keys >> /root/.ssh/authorized_keys

apt-get update
apt-get install -y locales chrony tzdata nfs-common
locale-gen en_US.UTF-8
dpkg-reconfigure -f noninteractive locales
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
dpkg-reconfigure -f noninteractive tzdata
