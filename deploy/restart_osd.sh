#!/bin/bash
# Liu Chaoyang (chaoyanglius@gmail.com)
# This script is used to restart osd in batch.
# **Note:** This script must be run by root
# 2019-07-08 14:59

# current user must be root
if [[ $(whoami) != "root" ]]
then
    echo "[ WARN]: This script must be run by root!"
    exit 1
fi

if [[ $# -eq 0 ]]; then
    echo "[ WARN]: Please input osd id!"
    exit 1 
fi

osd_list=("$@")

# start osd
for osd_id in ${osd_list[@]}; do
	echo "[ INFO]: Restarting OSD '$osd_id'..."
    ceph-osd -i $osd_id --cluster ceph --osd-data /var/lib/ceph/osd/ceph-$osd_id
	echo "[ INFO]: Restart OSD '$osd_id' succeed."
done

exit 0
