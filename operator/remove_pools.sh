#!/bin/bash
# Delete pool in batch
# Written by Liu Chaoyang

BASEDIR=$(dirname $0)
. ${BASEDIR}/sttest_config.cfg

for i in $(seq 0 $((pool_num-1))); do
    ceph osd pool delete $pool_name$i $pool_name$i --yes-i-really-really-mean-it
    if [[ 0 -ne $? ]]; then
        echo "[ERROR]: Delete pool $pool_name$i failed!"
        exit -1
    fi
done

echo "[INFO]: Delete pools succeeded."

exit 0
