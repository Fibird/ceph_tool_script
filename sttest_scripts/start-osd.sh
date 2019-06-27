#!/bin/bash -x



BASEDIR=$(dirname $0)
. ${BASEDIR}/config.sh
. ${BASEDIR}/file_path.sh
. ${BASEDIR}/functions.sh
. ${BASEDIR}/osd-config.sh


ceph-osd -i $ID --cluster $cluster_name --osd-data $OSD_DATA



