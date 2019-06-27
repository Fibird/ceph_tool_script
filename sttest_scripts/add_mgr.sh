#!/bin/bash 
# Liu Chaoyang (chaoyanglius@gmail.com)
# This script is used to add mgr into ceph. 
# **Note:** This script must be run by root
# 2019-05-14 16:10

# current user must be root
if [[ $(whoami) != "root" ]]
then
    echo "This script must be run by root!"
    exit 1
fi

host_name=$(hostname)

mgr_name=$host_name

ceph auth get-or-create mgr.$mgr_name mon 'allow *' osd 'allow *' mds 'allow *'
ceph auth caps mgr.$mgr_name mon 'allow *' osd 'allow *' mds 'allow *'
mkdir -p /var/lib/ceph/mgr/ceph-$mgr_name
ceph auth get mgr.$mgr_name -o  /var/lib/ceph/mgr/ceph-$mgr_name/keyring
ceph-mgr -i $mgr_name 
