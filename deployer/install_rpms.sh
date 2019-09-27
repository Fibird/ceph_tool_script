#!/bin/bash

if [[ -n "$1" ]]; then
    rpm_dir=$1
else
    echo "[ERROR]: No rpm directory given!"
    exit -1
fi

rpm -ivh --nodeps "$rpm_dir"/*.rpm

exit 0
