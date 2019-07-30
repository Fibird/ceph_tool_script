#!/bin/bash -x



BASEDIR=$(dirname $0)
. ${BASEDIR}/config.sh
. ${BASEDIR}/file_path.sh
. ${BASEDIR}/functions.sh
. ${BASEDIR}/osd-config.sh


UUID=$(uuidgen)

OSD_SECRET=$(ceph-authtool --gen-print-key)

ID=$(echo "{\"cephx_secret\": \"$OSD_SECRET\"}" | \
   ceph osd new $UUID -i - \
   -n client.bootstrap-osd -k $BOOSTRAP_OSD_KEYRING)

mkdir -p $OSD_DATA

umount $OSD_DATA

mkfs.xfs -f $OSD_DEV

mount $OSD_DEV $OSD_DATA

ceph-authtool --create-keyring $OSD_DATA/keyring \
     --name osd.$ID --add-key $OSD_SECRET

echo "ceph-osd -i $ID --mkfs --osd-uuid $UUID --osd-data $OSD_DATA"

ceph-osd -i $ID --mkfs --osd-uuid $UUID --osd-data $OSD_DATA
# 0 7d5f5d05-09ae-4c9c-a990-e72a17f6f145
