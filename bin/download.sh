#!/bin/bash

remote=$1
target=$2
bwlimit=$3

opts="--append -zh --progress"
test -n "$bwlimit" && opts="$opts --bwlimit $bwlimit"

sort | while read p; do
    rsync $opts $remote:"\"$p\"" "$target"

    echo
    echo -n 'Remote checksum: '
    ssh -n $remote md5sum "\"$p\"" | cut -d' ' -f1
    echo -n 'Local checksum:  '
    gmd5sum "$target/$(basename "$p")" | cut -d' ' -f1
    echo
done
