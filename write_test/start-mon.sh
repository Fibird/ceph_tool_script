#!/bin/bash

BASEDIR=$(dirname $0)
. ${BASEDIR}/config.sh
. ${BASEDIR}/file_path.sh


ceph-mon -i $host_name --cluster $cluster_name




