#!/bin/bash

ceph osd getcrushmap -o .crushmap
crushtool -d crushmap -o .crushmap-decompile
\rm .crushmap

sed -i s/"step chooseleaf firstn 0 type host"/"step chooseleaf firstn 0 type osd"/g .crushmap-decompile

crushtool -c .crushmap-decompile -o .crushmap
ceph osd setcrushmap -i .crushmap

\rm .crushmap-decompile 

exit 0
