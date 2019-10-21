#!/bin/bash

min_br=$1
min_lease=$2
min_rent=$3
max_rent=$4

start_ut=`date -d '+2 hours' +%s`
end_ut=`date -d '+3 weeks' +%s`

list-properties() {
    cat << EOF
The Montclaire:109
Magnolia Square:333
Windsor Ridge:170
Bristol Commons:030
Brookside Oaks:220
Marina Cove:094
Villa Granada:sfo1256
Summerhill Park:129
Regency At Mountain View:387
Riley Square:357
Via:186
Reed Square:130
Solstice:sfo1273
Lawrence Station:sfo1267
1000 Kiely:121
EOF
}

list-properties | while IFS=: read -r name id; do
    seq $start_ut 86400 $end_ut | parallel -P 4 bash ./get-listings.sh $id $min_br $min_lease $min_rent $max_rent \"$name\" | sort -u
done
