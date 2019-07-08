/usr/sbin/groupadd ceph -g 167 -o -r
/usr/sbin/useradd ceph -u 167 -o -r -g ceph -s /sbin/nologin -c "Ceph daemons"
chown -R ceph:ceph /etc/ceph/
chown -R ceph:ceph /var/run/ceph
mkdir -p /var/log/ceph
chown -R ceph:ceph /var/log/ceph
chown -R ceph:ceph /var/lib/ceph
