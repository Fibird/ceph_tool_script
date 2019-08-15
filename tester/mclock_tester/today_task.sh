./dmclock_test_script2.sh
sleep 3

\cp ceph.conf.0 /etc/ceph/ceph.conf
systemctl restart ceph-osd@[0-2]
sleep 15
./dmclock_test_script2.sh

sleep 3
\cp ceph.conf.1 /etc/ceph/ceph.conf
systemctl restart ceph-osd@[0-2]
sleep 15
./dmclock_test_script2.sh

sleep 3
\cp ceph.conf.2 /etc/ceph/ceph.conf
systemctl restart ceph-osd@[0-2]
sleep 15
./dmclock_test_script2.sh
