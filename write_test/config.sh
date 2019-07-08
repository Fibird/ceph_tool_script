#!/bin/bash

####################
# This file contains config options similar to ceph.conf
# It is a shell script that will be executed. The config
# options then become variables.
# ref: http://ceph.com/docs/master/install/manual-deployment/
#
# This file is for you to config.
####################

# The code branch on ceph github. Firefly is the newest release now (March, 2014).
#git_branch=firefly

# The user of ceph serivces. Monitor and osd will be installed under this user account.
#ceph_user=ceph_service

# Your hostname to install ceph all-in-one. You can use localhost
host_name=BJ-IDC1-10-10-30-143

# Please replace it with another uuid. Use command uuidgen to generate a uuid.
fsid=0bcc96c7-444a-42da-bb16-77793160c072

# Ceph supports setting custom custer name. On default it is 'ceph'.
cluster_name=ceph

# Monitor list. You can install multiple monitors on single node, at least 3.
# Use space, and only space to separate multiple monitors. Don't omit double quotes.
mon_list="BJ-IDC1-10-10-30-143"  # The name of each monitor

# mon_ip_list="10.10.30.143"
mon_ip_list="127.0.0.1"
mon_port_list="6790 6791 6792"

# How many OSDs you want to install on all-in-one host
#osd_count=3

# Seems have no big effect on all-in-one condition
public_network=10.10.120.143/24

osd_op_queue=wpq
mon_allow_pool_delete=true
osd_op_num_shards_hdd=5
osd_op_num_shards_ssd=8
objecter_inflight_op_bytes=0
objecter_inflight_ops=0

osd_pool_default_size=1
osd_pool_default_min_size=1

# this is used by test-all.sh. set to true will test whether service is working after restart. This is slow and, on the other hand, restarting sometimes (rarely) may cause trouble, see TODO-01.
#test_restart=true

debug_config=./debug-config

