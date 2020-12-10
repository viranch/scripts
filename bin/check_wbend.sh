#!/bin/bash -ue

source ~/.env/pb

mkdir -p ~/.cache/rentals

while read prop; do
    curl https://doorway-api.knockrentals.com/v1/property/$prop/unit-listings -s | jq -r '.unit_listings[].listing | select(.floorplan.bedrooms >= 2 and .floorplan.bathrooms >= 2) | "#"+.external.unit.id+" / "+.external.available_date+" / $"+(.leasing.monthlyRent|tostring)+" / "+.external.unit.market_status' | sort > ~/.cache/rentals/$prop.new
    test -f ~/.cache/rentals/$prop || touch ~/.cache/rentals/$prop
    diff="$(diff -U 0 ~/.cache/rentals/$prop ~/.cache/rentals/$prop.new | tail -n +4)"
    test -z "$diff" && continue
    curl https://api.pushbullet.com/v2/pushes -H 'Content-Type: application/json' -H "Access-Token: $PB_TOKEN" -d '{"title": "Rent watcher", "body": "'"$(echo $diff | tr '\n' ';' | sed 's/;/\\n/g')"'\n\n'"$(cat ~/.cache/rentals/$prop.new | tr '\n' ';' | sed 's/;/\\n/g')"'", "type": "note"}'
    mv ~/.cache/rentals/$prop.new ~/.cache/rentals/$prop
done << EOF
2005479
EOF
