#!/bin/bash -x

BASEDIR=$(dirname $0)
. ${BASEDIR}/config.sh
. ${BASEDIR}/file_path.sh
. ${BASEDIR}/functions.sh

mkdir -p $BOOSTRAP_OSD_FOLDER

ceph-authtool --create-keyring $TMP_MON_KEYRING --gen-key -n mon. --cap mon 'allow *'

ceph-authtool --create-keyring $ADMIN_KEYRING --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'

ceph-authtool --create-keyring $BOOSTRAP_OSD_KEYRING --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd'

ceph-authtool $TMP_MON_KEYRING --import-keyring $ADMIN_KEYRING 

ceph-authtool $TMP_MON_KEYRING --import-keyring $BOOSTRAP_OSD_KEYRING

