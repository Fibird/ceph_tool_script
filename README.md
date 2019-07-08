# Ceph Tool Scripts

Several scripts to help develop ceph easily.

## Deploy

In deploy directory:

- deploy\_on\_single\_node.sh: help you deploy ceph on a single host from yum source.
- install\_build\_ceph.sh: help you deploy ceph on a single host from source code.

## Osd

In osd directory, there are some scripts about osd.

- primary\_pg\_tuner.sh: adjust primary pg to mean(obsolete).
- print\_pgnum\_by\_osd.sh: print pg number by osd.
- rm\_osd\_in\_batch.sh: rm osd in batch

## Contributing

### Log level

There are three log levels: INFO, WARN and ERROR. 

The return code is very simple:

- INFO: program return 0
- WARN: program return 1
- ERROR: program return -1

So you should add detailed description in log.


