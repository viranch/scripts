#!/bin/sh

# Reliance BB usage

if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]
then
    echo "Usage: usage from-date [to-date]"
    exit 1
fi

num="9375254719"
if [ -z "$2" ]
then
    enddate=$(date +%F)
else
    enddate=$2
fi

html=$(curl -s "http://myservices.relianceada.com/datausage/jsp/ProcessCDRRequest?Mdn=$num&StartDate=$1&EndDate=$enddate&ProductType=1&RequestType=Query")
n=$(echo "$html"|grep greybghdrfortotal -A 6|tail -n1|sed "s/.*<center>//g"|sed "s/<\/center>.*//g")
echo "$n" GB

