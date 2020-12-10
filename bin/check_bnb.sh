#!/bin/bash

source ~/.env/pb

notify() {
    curl https://api.pushbullet.com/v2/pushes -H 'Content-Type: application/json' -H "Access-Token: $PB_TOKEN" -d '{"title": "BnB Watcher", "body": "'"$1"' available on '$2'", "type": "note"}'
}


while read unit_id; do
    old=`cat ~/.cache/bnb/$unit_id`

    html="$(curl -s "https://www.vacasa.com/unit.php?UnitID=$unit_id")"
    unit="$(echo "$html" | grep -F "Unit: " -A 4 | head -5 | paste -sd" " -| sed 's/^[^:]*://g;s/\(\S\+\):/"\1":/g' | sed "s/'/\"/g" | jq -r .UnitName)"
    new=`echo "$html" | grep -F "Availability: " | sed 's/^[^:]*://g' | jq -r '.[] | select(.bookable) | .date' 2>/dev/null | head -1`

    test -n "$old" && [[ $old -ne $new ]] && notify "$unit" $new

    echo $new > ~/.cache/bnb/$unit_id
done << EOF
4087
EOF
