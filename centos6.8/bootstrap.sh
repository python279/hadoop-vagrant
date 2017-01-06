#!/usr/bin/env bash

cp /vagrant/hosts /etc/hosts
cp /vagrant/resolv.conf /etc/resolv.conf
yum install ntp vim dos2unix -y
service ntpd start
service iptables stop
mkdir -p /root/.ssh; chmod 600 /root/.ssh; cp /home/vagrant/.ssh/authorized_keys /root/.ssh/

#Again, stopping iptables
/etc/init.d/iptables stop

cp /vagrant/insecure_private_key /root/ec2-keypair
chmod 600 /root/ec2-keypair
