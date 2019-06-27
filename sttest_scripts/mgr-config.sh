#!/bin/bash 

ceph auth get-or-create mgr.openstack mon 'allow *' osd 'allow *' mds 'allow *'
ceph auth caps mgr.openstack mon 'allow *' osd 'allow *' mds 'allow *'
mkdir -p /var/lib/ceph/mgr/ceph-openstack
ceph auth get mgr.openstack -o  /var/lib/ceph/mgr/ceph-openstack/keyring
ceph-mgr -i openstack
