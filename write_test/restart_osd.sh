#!/bin/bash
# By Liu Chaoyang

# current user must be root
if [[ $(whoami) != "root" ]]
then
    echo "This script must be run by root!"
    exit 1
fi

osd_list=("$@")

# start osd
for osd_id in ${osd_list[@]}; do
	echo $osd_id
    ceph-osd -i $osd_id --cluster ceph --osd-data /var/lib/ceph/osd/ceph-$osd_id
done

