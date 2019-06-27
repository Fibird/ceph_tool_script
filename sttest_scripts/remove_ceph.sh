rpm -e --nodeps `rpm -aq | grep ceph`
rpm -e --nodeps `rpm -aq | grep rados`
rpm -e --nodeps `rpm -aq | grep rbd`
rpm -e --nodeps `rpm -aq | grep rgw`
