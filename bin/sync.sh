#!/bin/bash

remote=$1
shift

ssh -fN $remote || exit 1

function find_files() {
    remote=$1; shift
    for opt in $@; do
        src_dir=`echo $opt | cut -d':' -f1`
        rename=`echo $opt | cut -d':' -f2`
        test -z "$rename" && rename=0
        dst_dir=`echo $opt | cut -d':' -f3`
        test -z "$dst_dir" && dst_dir="." || mkdir -p "$dst_dir"

        echo "Finding $src_dir ..." 1>&2
        ssh $remote "find $src_dir -type f ! -name \*.part -size +75M" | while read src_path; do
            #echo $src_path 1>&2
            src_path_dir=$(basename "`dirname "$src_path"`")
            src_path_ext=`echo ${src_path##*.}`
            [[ $rename -eq 0 || "$src_path_dir" == "$(basename "$src_dir")" ]] && dst_file=`basename "$src_path"` || dst_file=`basename "$src_path_dir"`.$src_path_ext
            echo "$src_path;$dst_dir/$dst_file"
            #link=`echo http://$remote/downloads/${src_path##$src_dir} | sed 's/ /%20/g'`
            #echo "$link;$dst_file"
        done
    done
}

function download() {
    while read line; do
        link=${line%;*}
        filename=${line##*;}

        #wget -c "$link" -O ~/Downloads/"$filename" --limit-rate=5M
        #scp $1:"\"$link\"" "$filename"
        echo "Downloading $link ..."
        rsync --append -zh --progress --bwlimit 5000 $1:"\"$link\"" "$filename"
    done
}

find_files $remote $@ | download $remote
