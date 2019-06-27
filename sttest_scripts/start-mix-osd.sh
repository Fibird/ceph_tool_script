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


ceph-osd -i $ID --cluster $cluster_name --osd-hdd-data $HDD_DATA --osd-ssd-data $SSD_DATA --use_bluestore --no-mon-config





