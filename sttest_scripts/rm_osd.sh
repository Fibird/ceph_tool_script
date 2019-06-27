#!/bin/bash

if [[ $# -eq 0 ]]; then
	echo "Please input osd ID(s)!"	
	exit -1
fi

ids=("$@")
for id in ${ids[@]}; do
	ceph osd out osd.$id
	ceph osd down osd.$id
	ceph osd rm osd.$id
	ceph osd crush rm osd.$id
	ceph auth del osd.$id
	umount /var/lib/ceph/osd/ceph-$id
done


