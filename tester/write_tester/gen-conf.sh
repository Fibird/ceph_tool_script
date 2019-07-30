#!/bin/bash

#########################
# This file generate the basic /etc/ceph.conf
# refer to http://ceph.com/docs/master/install/manual-deployment/
# You may modify it to customize.
#########################

BASEDIR=$(dirname $0)
. ${BASEDIR}/config.sh
. ${BASEDIR}/file_path.sh
. ${BASEDIR}/functions.sh


# create the ceph config file
sudo mkdir -p $CONF_FOLDER
sudo mkdir -p $BOOSTRAP_OSD_FOLDER
sudo touch $CONF_FILE
sudo chmod a+r $CONF_FILE

# output default config file
sudo echo -e "" | sudo tee $CONF_FILE > /dev/null

sudo echo -e "[global]" | sudo tee -a $CONF_FILE > /dev/null
sudo echo -e "fsid = $fsid" | sudo tee -a $CONF_FILE > /dev/null
sudo echo -e mon initial members = $(list_add_comma "$mon_list") | sudo tee -a $CONF_FILE > /dev/null
sudo echo -e mon host = $(list_add_comma "$mon_ip_list") | sudo tee -a $CONF_FILE > /dev/null
sudo echo -e "public network = $public_network" | sudo tee -a $CONF_FILE > /dev/null

sudo echo -e "auth cluster required = cephx" | sudo tee -a $CONF_FILE > /dev/null
sudo echo -e "auth service required = cephx" | sudo tee -a $CONF_FILE > /dev/null
sudo echo -e "auth client required = cephx" | sudo tee -a $CONF_FILE > /dev/null

sudo echo -e "osd journal size = 1024 " | sudo tee -a $CONF_FILE > /dev/null
sudo echo -e "filestore xattr use omap = true" | sudo tee -a $CONF_FILE > /dev/null
#sudo echo -e "osd pool default size = 3 " | sudo tee -a $CONF_FILE > /dev/null
#sudo echo -e "osd pool default min size = 1 " | sudo tee -a $CONF_FILE > /dev/null
#sudo echo -e "osd pool default pg num = 512 " | sudo tee -a $CONF_FILE > /dev/null
#sudo echo -e "osd pool default pgp num = 512 " | sudo tee -a $CONF_FILE > /dev/null

# multiple osd on single node needs to set this to 0 (default is 1). ref: http://ceph.com/docs/dumpling/start/quick-ceph-deploy/ Single Node Quick Start
#sudo echo -e "osd crush chooseleaf type = 0 " | sudo tee -a $CONF_FILE > /dev/null
sudo echo -e "osd_op_queue=mclock_pool" | sudo tee -a $CONF_FILE > /dev/null

sudo echo -e "mon_allow_pool_delete=true" | sudo tee -a $CONF_FILE > /dev/null
sudo echo -e "osd_op_num_shards_hdd=1" | sudo tee -a $CONF_FILE > /dev/null
sudo echo -e "osd_op_num_shards_ssd=1" | sudo tee -a $CONF_FILE > /dev/null
sudo echo -e "osd_op_num_threads_per_shard_ssd=1" | sudo tee -a $CONF_FILE > /dev/null
sudo echo -e "osd_op_num_threads_per_shard_hdd=1" | sudo tee -a $CONF_FILE > /dev/null
sudo echo -e "osd_op_num_shards=1" | sudo tee -a $CONF_FILE > /dev/null

sudo echo -e "objecter_inflight_op_bytes=0" | sudo tee -a $CONF_FILE > /dev/null
sudo echo -e "objecter_inflight_ops=0" | sudo tee -a $CONF_FILE > /dev/null

sudo echo -e "osd_pool_default_size=1" | sudo tee -a $CONF_FILE > /dev/null
sudo echo -e "osd_pool_default_min_size=1" | sudo tee -a $CONF_FILE > /dev/null

#sudo echo -e "osd_deep_scrub_interval = 10" | sudo tee -a $CONF_FILE > /dev/null
#sudo echo -e "osd_scrub_max_interval = 10" | sudo tee -a $CONF_FILE > /dev/null
#sudo echo -e "osd_scrub_min_interval = 10" | sudo tee -a $CONF_FILE > /dev/null
#sudo echo -e "osd_scrub_priority = 63" | sudo tee -a $CONF_FILE > /dev/null

#sudo echo -e "osd_op_queue_mclock_client_op_lim = 0" | sudo tee -a $CONF_FILE > /dev/null
#sudo echo -e "osd_op_queue_mclock_client_op_res = 1" | sudo tee -a $CONF_FILE > /dev/null
#sudo echo -e "osd_op_queue_mclock_client_op_wgt = 1" | sudo tee -a $CONF_FILE > /dev/null

#sudo echo -e "osd_op_queue_mclock_scrub_lim = 0" | sudo tee -a $CONF_FILE > /dev/null
#sudo echo -e "osd_op_queue_mclock_scrub_res = 1" | sudo tee -a $CONF_FILE > /dev/null
#sudo echo -e "osd_op_queue_mclock_scrub_wgt = 1" | sudo tee -a $CONF_FILE > /dev/null






