#!/usr/bin/env bash

cp /vagrant/hosts /etc/hosts
cp /vagrant/resolv.conf /etc/resolv.conf
yum install ntp -y
service ntpd start
service iptables stop
mkdir -p /root/.ssh; chmod 600 /root/.ssh; cp /home/vagrant/.ssh/authorized_keys /root/.ssh/

#Again, stopping iptables
/etc/init.d/iptables stop

sudo cp /vagrant/insecure_private_key /root/ec2-keypair
sudo chmod 600 /root/ec2-keypair

# Workaround from https://www.digitalocean.com/community/questions/can-t-install-mysql-on-centos-7
rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
#Workaround for missing network https://github.com/mitchellh/vagrant/issues/8096
sudo service network restart
