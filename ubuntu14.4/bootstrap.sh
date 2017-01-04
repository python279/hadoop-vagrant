#!/usr/bin/env bash
cp /vagrant/hosts /etc/hosts
cp /vagrant/resolv.conf /etc/resolv.conf
cp /vagrant/sources.list /etc/apt/sources.list
mkdir -p /root/.ssh; chmod 600 /root/.ssh; cp /home/vagrant/.ssh/authorized_keys /root/.ssh/

cp /vagrant/insecure_private_key /root/insecure_private_key
chmod 600 /root/insecure_private_key
