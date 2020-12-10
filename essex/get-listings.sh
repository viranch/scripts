#!/bin/bash

id=$1
min_br=$2
min_bt=$3
max_rent=$4
name=$5
ut=$6

mkdir -p debug
fname="debug/${id}_$ut.json"
curl -s "https://www.essexapartmenthomes.com/api/get-available/$id/$(date -d @$ut +%m-%d-%Y)" > $fname
cat $fname | jq -r '.[] | select((.beds|tonumber) >= '$min_br') | select((.baths|tonumber) >= '$min_bt') | .floorplans[].units[] | .unit_code + ":" + .beds + ":" + .available_date + ":" + .square_feet' | while IFS=: read -r unit_code beds avail_date sqft; do
    avail_ut=`date -d $avail_date +%s`
    max_ut=`echo -e "$ut\n$avail_ut" | sort -n | tail -1`
    move_in=`date -d @$max_ut +%m/%d/%Y`
    rent_range="$min_rent and $max_rent"
    #[[ $max_ut -le `date -d '+1 month' +%s` ]] &&
    #rent_range="$min_rent and $max"  # lease break
    fname="debug/${id}_${max_ut}_${unit_code}.json"
    test -f $fname || curl -s https://www.essexapartmenthomes.com/rentcafe-pricing-and-application-url --data-urlencode "move_in_date=$move_in" --data-urlencode "property_code=$id" --data-urlencode "unit_id=$unit_code" > $fname
    cat $fname | jq -r ".pricing|select(.!=null)|.[] | select($max_rent >= (.Rent|tonumber)) | .Term + \":\" + .Rent" | while IFS=: read -r term rent; do
        echo $name : $beds BR : $sqft sqft : unit $unit_code : Move in `date -d @$max_ut +%d/%b` : $term months : $rent
    done
done
