#!/bin/bash

if [[ $# -ne 1 ]]
then
  echo "Please specify public network!"
  exit 1
fi

ip_seg=$1
node_name=ceph-master
ipadd=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')

# backup hosts file
cur_time=`date +"%Y-%m-%d-%H-%M-%S"`
cp /etc/hosts /etc/hosts.$cur_time.bk
# add node ip into hosts
echo "$ipadd $node_name" >> /etc/hosts

# copy keyring file
ssh-keygen -t rsa
ssh-copy-id root@$node_name

mkdir ~/ceph-cluster
cd ~/ceph-cluster

# install necessary software
yum install tree nmap sysstat lrzsz dos2unix wegt git net-tools -y

# install ntp
yum install -y ntp

# update yum source
rm -rf /etc/yum.repos.d/*.repo
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
sed -i '/aliyuncs/d' /etc/yum.repos.d/CentOS-Base.repo
sed -i 's/$releasever/7/g' /etc/yum.repos.d/CentOS-Base.repo
sed -i '/aliyuncs/d' /etc/yum.repos.d/epel.repo
yum clean all
yum makecache fast

# install ceph-deploy
yum install http://mirrors.163.com/ceph/rpm-mimic/el7/noarch/ceph-deploy-1.5.39-0.noarch.rpm

# create ceph cluster
ceph-deploy new $node_name

# set public network
echo "public_network=$ip_seg/24" >> ./ceph.conf

# install ceph components
ceph-deploy install --release mimic --repo-url http://mirrors.163.com/ceph/rpm-mimic/el7 --gpg-url http://mirrors.163.com/ceph/keys/release.asc $node_name

# initial monitor node
ceph-deploy mon create-initial
# set this node as admin
ceph-deploy admin $node_name

# set manager on this node
ceph-deploy mgr create $node_name
