#!/bin/bash

BASEDIR=$(dirname $0)
. ${BASEDIR}/mclock_test.cfg

for i in $(seq 0 $((pool_num-1))); do
    pool_name=$pool_name_prefix$i
    ceph osd pool create $pool_name $pg_num_per_pool 
    if [[ 0 -ne $? ]]; then
        echo "[ERROR]: Create pool $pool_name failed!"
        exit -1
    fi
    ceph osd pool application enable $pool_name freeform 
done

echo "[INFO]: Create pools succeeded."

exit 0
