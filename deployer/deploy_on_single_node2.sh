#!/bin/bash
# Liu Chaoyang (chaoyanglius@gmail.com)
# This script is used to deploy ceph on single node
# **Note:** This script must be run by root
# 2019-11-16 10:24

# current user must be root
if [[ $(whoami) != "root" ]]
then
    echo "This script must be run by root!"
    exit 1
fi

node_name=$(hostname)
ipadd=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
public_network=$ipadd/24

# backup hosts file
cur_time=`date +"%Y-%m-%d-%H-%M-%S"`
\cp /etc/hosts /etc/hosts.$cur_time.bk
# add node ip into hosts
echo "$ipadd $node_name" >> /etc/hosts

# clean older dir
rm -rf ~/ceph_cluster

mkdir ~/ceph_cluster
cd ~/ceph_cluster

# update source
wget -q -O- 'https://mirrors.163.com/ceph/keys/release.asc' | sudo apt-key add -
echo "deb http://mirrors.163.com/ceph/debian-mimic/ $(lsb_release -sc) main" >> /etc/apt/sources.list
sudo apt-get clean
sudo apt-get update

# install ceph-deploy
sudo apt-get install ceph-deploy

# remove older ceph and ceph data
ceph-deploy purge $node_name
ceph-deploy purgedata $node_name

# create ceph cluster
ceph-deploy new $node_name

# set public network
echo "public_network=$public_network" >> ~/ceph_cluster/ceph.conf

# install ceph components
ceph-deploy install $node_name

# initial monitor node
ceph-deploy mon create-initial
# set this node as admin
ceph-deploy admin $node_name

# set manager on this node
ceph-deploy mgr create $node_name
