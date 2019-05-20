#!/bin/bash
# Liu Chaoyang (chaoyanglius@gmail.com)
# This script is used to remove ceph which is installed manually.
# **Note:** This script must be run by root
# 2019-05-13 15:22

#osd_list=($(ceph osd ls))

# current user must be root
if [[ $(whoami) != "root" ]]
then
    echo "This script must be run by root!"
    exit 1
fi

# set systemd path
SYSTEMD_ETC_DIR="/etc/systemd/system"
SYSTEMD_USR_DIR="/usr/lib/systemd/system"

# get ceph source path
CEPH_SOURCE_PATH="/root/gitReps/ceph"

# kill all osd daemon if existed
for pid in $(ps -ef | grep osd | awk '{print $2}'); do
     if [ $pid != $$ ]; then
         echo "killing process $pid ..."
         sudo kill $pid > /dev/null 2>&1
     fi
done

#for i in ${osd_list[@]}; do
#    umount

# kill all ceph daemon if existed
for pid in $(ps -ef | grep ceph | awk '{print $2}'); do
     if [ $pid != $$ ]; then
         echo "killing process $pid ..."
         sudo kill $pid > /dev/null 2>&1
     fi
done

#cd $CEPH_SOURCE_PATH/build
#make uninstall

\rm -rf /etc/ceph/
\rm -rf /var/lib/ceph/
\rm -rf /var/lib/ceph/
# remove older ceph systemd service
# use absolute 'rm' command instead of aliased(only valid on root)
# you can check it by 'alias' command
\rm -rf $SYSTEMD_ETC_DIR/ceph-*.wants
\rm -rf $SYSTEMD_ETC_DIR/ceph*.wants
\rm -rf $SYSTEMD_USR_DIR/ceph-*.service
\rm -rf $SYSTEMD_USR_DIR/ceph-*.service
