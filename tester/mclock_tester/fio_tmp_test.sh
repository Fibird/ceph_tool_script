ceph osd pool set test0 qos_res 1
ceph osd pool set test0 qos_wgt 1
ceph osd pool set test0 qos_lim 800

for i in {1..4}; do
    ceph osd pool set test$i qos_res 1
    ceph osd pool set test$i qos_wgt 1
    ceph osd pool set test$i qos_lim 0
done

#fio -ioengine=rbd -clientname=admin -pool=test0 -rbdname=rbd0 -iodepth=4 -runtime=100 -rw=write -bs=16K -numjobs=1 -name=16K_write_0 > fio_tmp_log0 &

#for i in {1..2}; do
for i in {1..4}; do
    fio -ioengine=rbd -clientname=admin -pool=test$i -rbdname=rbd$i -iodepth=128 -runtime=100 -rw=write -bs=16K -numjobs=1 -name=16K_write_$i > fio_tmp_log$i &
done

fio -ioengine=rbd -clientname=admin -pool=test0 -rbdname=rbd0 -iodepth=128 -runtime=100 -rw=write -bs=16K -numjobs=2 -name=16K_write_0 > fio_tmp_log0
