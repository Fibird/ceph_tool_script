#!/bin/bash



BASEDIR=$(dirname $0)
. ${BASEDIR}/config.sh
. ${BASEDIR}/file_path.sh
. ${BASEDIR}/functions.sh
. ${BASEDIR}/mix-osd-config.sh


UUID=$(uuidgen)

OSD_SECRET=$(ceph-authtool --gen-print-key)

ID=$(echo "{\"cephx_secret\": \"$OSD_SECRET\"}" | \
   ceph osd new $UUID -i - \
   -n client.bootstrap-osd -k $BOOSTRAP_OSD_KEYRING)

mkdir -p $HDD_DATA
mkdir -p $SSD_DATA

umount $HDD_DATA
umount $SSD_DATA

mkfs.xfs -f $HDD_DEV
mkfs.xfs -f $SSD_DEV

mount $HDD_DEV $HDD_DATA
mount $SSD_DEV $SSD_DATA

ceph-authtool --create-keyring $HDD_DATA/keyring \
     --name osd.$ID --add-key $OSD_SECRET


echo "ceph-osd -i $ID --mkfs --osd-uuid $UUID --osd-hdd-data $HDD_DATA --osd-ssd-data $SSD_DATA --use_bluestore"

ceph-osd -i $ID --mkfs --osd-uuid $UUID --osd-hdd-data $HDD_DATA --osd-ssd-data $SSD_DATA --use_bluestore




