#!/bin/bash

remote=$1
find_opts=$2
grep_opts=$3
destination=$4
bwlimit=$5

alias ssh='/usr/bin/ssh -4'

#ssh -O exit $remote
ssh -O check $remote 2>/dev/null || ssh -fN $remote || exit 1

function find_files() {
    remote=$1; shift
    ssh $remote "find $@ -type f ! -name \*.part -size +10M"
}

function download() {
    remote=$1
    dest=$2
    bwlimit=$3

    test -z "$dest" && cat && return

    rsync_opts="--append -zh --progress"
    test -n "$bwlimit" && rsync_opts="$rsync_opts --bwlimit $bwlimit"

    while read p; do
        rsync $rsync_opts $remote:"\"$p\"" "$dest" || exit 1

        echo
        remote_md5=`ssh -n $remote md5sum "\"$p\"" | cut -d' ' -f1`
        local_md5=`gmd5sum "$dest/$(basename "$p")" | cut -d' ' -f1`
        if [[ $remote_md5 != $local_md5 ]]; then
            echo "Remote checksum != Local checksum: $remote_md5 != $local_md5"
        else
            ssh -n $remote sudo rm -v "\"$p\""
        fi
        echo
    done
}

test -z "$grep_opts" && grep_opts="^" # nullify grep, don't filter anything, show all

find_files $remote $find_opts | grep $grep_opts | sort | download $remote "$destination" $bwlimit
