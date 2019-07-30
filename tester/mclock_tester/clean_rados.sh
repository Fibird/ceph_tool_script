#!/bin/bash

for pid in $(ps aux | grep [r]ados | awk '{print $2}'); do 
    kill $pid
done

exit 0
