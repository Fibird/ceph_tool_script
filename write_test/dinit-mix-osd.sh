#!/bin/bash -x



BASEDIR=$(dirname $0)
. ${BASEDIR}/config.sh
. ${BASEDIR}/file_path.sh
. ${BASEDIR}/functions.sh
. ${BASEDIR}/mix-osd-config.sh


#UUID=$(uuidgen)

UUID=57a1100d-2923-4bbf-a5db-e360945dfc8e

#OSD_SECRET=$(ceph-authtool --gen-print-key)

OSD_SECRET=AQDGKGpcaudKFhAAfFuIvNFz31Uz/ZywYRUFYQ==

#ID=$(echo "{\"cephx_secret\": \"$OSD_SECRET\"}" | \
#   ceph osd new $UUID -i - \
#   -n client.bootstrap-osd -k $BOOSTRAP_OSD_KEYRING)

ID=0


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

gdb ceph-osd

set args -i 0  --osd-uuid 57a1100d-2923-4bbf-a5db-e360945dfc8e --osd-hdd-data /root/lhh/mnt/hdd_dir --osd-ssd-data /root/lhh/mnt/ssd_dir --use_bluestore

args = "-i $ID --mkfs --osd-uuid $UUID --osd-hdd-data $HDD_DATA --osd-ssd-data $SSD_DATA --use_bluestore"

echo $args > init_mix_osd_args

gdb -x $debug_config --args ceph-osd $args

#-i $ID --mkfs --osd-uuid $UUID --osd-hdd-data $HDD_DATA --osd-ssd-data $SSD_DATA --use_bluestore




