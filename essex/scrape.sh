#!/bin/bash

min_bd=$1
min_bt=$2
max_rent=$3

start_ut=`date -d '+1 month' +%s`
end_ut=`date -d '+2 months' +%s`

list-properties() {
    cat >/dev/null << EOF
Fourth & U:180
The Courtyards at 65th Street:460
Emme:362
Avenue 64:sfo1244
EOF
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
    seq $start_ut 86400 $end_ut | parallel -P 4 bash `dirname $0`/get-listings.sh $id $min_bd $min_bt $max_rent \"$name\" | sort -u
done
