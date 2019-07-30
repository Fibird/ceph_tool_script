#!/bin/bash

for i in ${osds[@]}; do
    ceph osd out osd.$i
    ceph osd down osd.$i
    ceph osd rm osd.$i
    systemctl stop ceph-osd@$i
    ceph osd crush rm osd.$i
    ceph auth del osd.$i
done

