#!/bin/bash

remote=$1
find_opts=$2
grep_opts=$3
destination=$4
bwlimit=$5

ss -O exit $remote 2>/dev/null
ssh -fN $remote || exit 1

function find_files() {
    remote=$1; shift
    ssh $remote "find $@ -type f ! -name \*.part -size +75M"
}

function download() {
    remote=$1
    dest=$2
    bwlimit=$3

    test -z "$dest" && cat && return

    rsync_opts="--append -zh --progress"
    test -n "$bwlimit" && rsync_opts="$rsync_opts --bwlimit $bwlimit"

    while read p; do
        echo rsync $rsync_opts $remote:"\"$p\"" "$dest" || exit 1
        continue

        echo
        echo -n 'Remote checksum: '
        ssh -n $remote md5sum "\"$p\"" | cut -d' ' -f1 & 2>/dev/null
        heresum=`gmd5sum "$dest/$(basename "$p")" | cut -d' ' -f1`
        wait
        echo "Local checksum:  $heresum"
        echo
    done
}

test -z "$grep_opts" && grep_opts="^" # nullify grep, don't filter anything, show all

find_files $remote $find_opts | (grep $grep_opts || exit 1) | sort | download $remote "$destination" $bwlimit
