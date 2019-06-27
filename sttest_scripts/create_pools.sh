#!/bin/bash

BASEDIR=$(dirname $0)
. ${BASEDIR}/sttest_config.cfg

for i in $(seq 0 $((pool_num-1))); do
    ceph osd pool create $pool_name$i $pg_num_per_pool 
    if [[ 0 -ne $? ]]; then
        echo "[ERROR]: Create pool $pool_name$i failed!"
        exit -1
    fi
    ceph osd pool application enable $pool_name$i freeform 
done

echo "[INFO]: Create pools succeeded."

exit 0
