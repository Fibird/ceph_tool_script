#!/bin/bash

# load scripts configurations
BASEDIR=$(dirname $0)
. ${BASEDIR}/sttest_config.cfg


for h in ${remote_host_list[@]}; do
    scp -r /etc/ceph/ $h:/etc/
done
