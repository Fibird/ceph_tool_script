#!/bin/bash -x



BASEDIR=$(dirname $0)
. ${BASEDIR}/config.sh
. ${BASEDIR}/file_path.sh
. ${BASEDIR}/functions.sh
. ${BASEDIR}/mix-osd-config.sh


ID=$1

if [ ! -n "$ID" ]; then
        echo "ID is null"
        exit
fi



args="-i $ID --cluster $cluster_name --osd-hdd-data $HDD_DATA --osd-ssd-data $SSD_DATA --use_bluestore --no-mon-config"

echo $args > start_mix_osd_args

gdb -x $debug_config --args ceph-osd $args










