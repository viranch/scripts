#!/bin/bash -e

cp_file=$HOME/.check_quota

touch $cp_file

quota_left=`curl -s http://122.160.230.125:8080/gbod/ | grep balanceQuotaInGB | sed 's/.*value="\(.*\)".*/\1/g' | cut -d. -f1`

prev=`cat $cp_file`
#[[ $((prev - quota_left)) -ge 5 ]]

echo | mail -S smtp=$(dig +short mx bxc.io | head -n1 | cut -d' ' -f2) -r cron@`hostname` -s "$((prev - quota_left))GB used - ${quota_left}GB left" k6khshyoiq2e@bxc.io

echo $quota_left | tee $cp_file
