#!/bin/bash

# load config
BASEDIR=$(dirname $0)
. ${BASEDIR}/sttest_config.cfg

for id in ${osd_list[@]}; do
    ceph osd out osd.$id
    ceph osd down osd.$id
    ceph osd crush rm osd.$id
    ceph auth del osd.$id
done

exit 0
