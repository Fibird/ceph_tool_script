#!/bin/bash 
# Liu Chaoyang (chaoyanglius@gmail.com)
# This script is used to add mgr in batch.
# **Note:** This script must be run by root
# 2019-07-08 13:45

# current user must be root
if [[ $(whoami) != "root" ]]
then
    echo "[ WARN]: This script must be run by root!"
    exit 1
fi

if [[ -n "$1" ]]; then
    mgr_name="$1"
else
    echo "[ WARN]: Please enter the mgr *name* follow this program!"
    exit 1
fi

# start mgr
ceph-mgr -i $mgr_name

exit 0
