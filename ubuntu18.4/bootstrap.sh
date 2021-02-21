#!/usr/bin/env bash

cp /vagrant/hosts /etc/hosts

mkdir -p /root/.ssh
chmod 700 /root/.ssh
cp /home/vagrant/.ssh/authorized_keys /root/.ssh/

cp /vagrant/insecure_private_key /root/insecure_private_key
chmod 600 /root/insecure_private_key

apt-get install -y locales openntpd tzdata
locale-gen en_US.UTF-8
dpkg-reconfigure -f noninteractive locales
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
dpkg-reconfigure -f noninteractive tzdata
