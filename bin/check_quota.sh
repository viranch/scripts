#!/bin/bash -e

cp_dir=$HOME/.check_quota
cp_file=`date +%d.%m.%Y`

mkdir -p $cp_dir
test ! -f $cp_dir/$cp_file

quota_left=`curl -s http://122.160.230.125:8080/gbod/ | grep balanceQuotaInGB | sed 's/.*value="\(.*\)".*/\1/g'`

test -n "$quota_left"

echo | mail -s "${quota_left}GB left" k6khshyoiq2e@bxc.io

touch $cp_dir/$cp_file
