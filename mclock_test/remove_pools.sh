#!/bin/bash
# Delete pool in batch
# Written by Liu Chaoyang

BASEDIR=$(dirname $0)
. ${BASEDIR}/mclock_test.cfg

for i in $(seq 0 $((pool_num-1))); do
    pool_name=$pool_name_prefix$i
    ceph osd pool delete $pool_name $pool_name --yes-i-really-really-mean-it
    if [[ 0 -ne $? ]]; then
        echo "[ERROR]: Delete pool $pool_name failed!"
        exit -1
    fi
done

echo "[INFO]: Delete pools succeeded."

exit 0
