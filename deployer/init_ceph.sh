#!/bin/bash 
# Liu Chaoyang (chaoyanglius@gmail.com)
# This script is used to config ceph which is installed manually.
# **Note:** This script must be run by root
# 2019-05-11 17:12

# current user must be root
if [[ $(whoami) != "root" ]]
then
    echo "This script must be run by root!"
    exit 1
fi

# remove all osd daemon
for pid in $(ps -ef | grep osd | awk '{print $2}'); do
     if [ $pid != $$ ]; then
         echo "killing process $pid ..."
         sudo kill $pid > /dev/null 2>&1
     fi
done

# kill all ceph daemon if existed
for pid in $(ps -ef | grep ceph | awk '{print $2}'); do
     if [ $pid != $$ ]; then
         echo "killing process $pid ..."
         sudo kill $pid > /dev/null 2>&1
     fi
done

public_network=($(ip -o -f inet addr show | awk '/scope global/ {print $4}'))
ipadd=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')

# use command uuidgen to generate a uuid.
ceph_cluster_fsid=$(uuidgen)

# your hostname to install ceph all-in-one. You can use localhost
host_name=$(hostname)
#host_name=ceph_master

# set cluster name
#cluster_name=$(hostname)
cluster_name=ceph

# Monitor list. You can install multiple monitors on single node, at least 3.
# Use space, and only space to separate multiple monitors. Don't omit double quotes.
mon_name=$host_name
mon_ip="127.0.0.1"

# ==========================generating ceph config file(default)==========================
# use absolute 'rm' command instead of aliased(only valid on root)
# you can check it by 'alias' command
touch .ceph.conf.tmp
\rm -rf /etc/ceph/
mkdir /etc/ceph/

echo "[global]" >> .ceph.conf.tmp
# ceph global setting
echo "fsid = $ceph_cluster_fsid" >> .ceph.conf.tmp
# Add the initial monitor(s) to your Ceph configuration file
echo "mon initial members = $mon_name" >> .ceph.conf.tmp
echo "mon host = $mon_ip" >> .ceph.conf.tmp
echo "public network = ${public_network[0]}" >> .ceph.conf.tmp
echo "auth cluster required = cephx" >> .ceph.conf.tmp
echo "auth service required = cephx" >> .ceph.conf.tmp
echo "auth client required = cephx" >> .ceph.conf.tmp
echo "osd journal size = 1024" >> .ceph.conf.tmp
echo "osd pool default size = 3" >> .ceph.conf.tmp
echo "osd pool default min size = 2" >> .ceph.conf.tmp
echo "osd pool default pg num = 333" >> .ceph.conf.tmp
echo "osd pool default pgp num = 333" >> .ceph.conf.tmp
#echo "osd crush chooseleaf type = 1" >> .ceph.conf.tmp 
# monitor initial setting
echo "[mon]" >> .ceph.conf.tmp
echo "mon_clock_drift_allowed = 0.5" >> .ceph.conf.tmp
echo "mon allow pool delete = true" >> .ceph.conf.tmp
echo "mon_data_avail_warn = 10" >> .ceph.conf.tmp

# use absolute 'cp' command instead of aliased(only valid on root)
# you can check it by 'alias' command
\cp .ceph.conf.tmp /etc/ceph/ceph.conf
# ======================================================================================

# ===================================create initial-user and keyring===================================
# create a keyring for your cluster and generate a monitor secret key
ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'

# Generate an administrator keyring, generate a client.admin user and add the user to the keyring
ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'

# Generate a bootstrap-osd keyring, generate a client.bootstrap-osd user and add the user to the keyring
\rm -rf /var/lib/ceph/bootstrap-osd
mkdir -p /var/lib/ceph/bootstrap-osd
ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd'

# Add the generated keys to the ceph.mon.keyring
ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring
# ========================================================================================================

# Generate a monitor map using the hostname(s), host IP address(es) and the FSID. Save it as /tmp/monmap
monmaptool --clobber --create --add $mon_name $mon_ip --fsid $ceph_cluster_fsid /tmp/monmap

# Create a default data directory (or directories) on the monitor host(s)
\rm -rf /var/lib/ceph/mon/
mkdir -p /var/lib/ceph/mon/

# Populate the monitor daemon(s) with the monitor map and keyring
ceph-mon --mkfs -i $host_name --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring

ceph-mon -i $host_name --cluster $cluster_name

# clean tmporary files
# use absolute 'rm' command instead of aliased(only valid on root)
# you can check it by 'alias' command
\rm .ceph.conf.tmp
