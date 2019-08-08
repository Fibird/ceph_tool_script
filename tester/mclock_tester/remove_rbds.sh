#!/bin/bash 

BASEDIR=$(dirname $0)
. ${BASEDIR}/mclock_test.cfg

for i in $(seq 0 $((pool_num-1))); do
    pool_name=$pool_name_prefix$i
    rbd_name=$rbd_name_prefix$i
    rbd unmap $pool_name/$rbd_name --pool $pool_name
    rbd rm $pool_name/$rbd_name
done

exit 0
