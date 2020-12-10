#!/bin/bash -ue

source ~/.env/xfinity
source ~/.env/pb

function notify() {
    percent=$1
    used=`jq -r .used /tmp/xu.json`
    total=`jq -r .total /tmp/xu.json`
    units=`jq -r .units /tmp/xu.json`
    until=`date -d $(jq -r '(.raw.usageMonths | reverse)[0].endDate' /tmp/xu.json) +"%b %d"`
    msg="Usage at ${percent}%: $((total-used))${units} left out of ${total}${units} until ${until}"
    curl https://api.pushbullet.com/v2/pushes -H 'Content-Type: application/json' -H "Access-Token: $PB_TOKEN" -d '{"title": "Xfinity", "body": "'"$msg"'", "type": "note"}'
}

mkdir -p ~/.cache/xfinity

$HOME/.local/bin/xfinity-usage -j > /tmp/xu.json

percent_usage=`jq -r '.used*100/.total | round' /tmp/xu.json`

for step in 99 95 90 85 80 0; do
    [[ $percent_usage -ge $step ]] || continue
    test -f ~/.cache/xfinity/$step && break
    notify $percent_usage
    rm -f ~/.cache/xfinity/*
    touch ~/.cache/xfinity/$step
    break
done

#rm /tmp/xu.json
