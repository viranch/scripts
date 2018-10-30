#!/bin/bash

state_file="$HOME/.airtel.quota"
tmp_file="/tmp/usage"
log_file="$HOME/airtel_usage.log"

echo -n > $tmp_file # truncate
while [[ "$(wc -l < $tmp_file)" == "0" ]]; do
    curl -s http://122.160.230.125:8080/gbod/gb_on_demand.do | sed 's/\r//g' | grep -E "(quota|limit):" | sed 's/&nbsp;//g' | sed 's/<\/\?li>//g' | sed 's/GB//g' | cut -d':' -f2 > $tmp_file
done
left=`head -n1 $tmp_file`
total=`tail -n1 $tmp_file`
rm -f $tmp_file

used=`echo $total-$left | bc`
usage="$used/$total GB used"

function pretty() {
    python2 << EOF
used = $1
units = ['GB', 'MB', 'KB', 'bytes']
unit = 0
if used > 0:
    while unit<len(units) and used<1:
        used *= 1024.0
        unit += 1
print used, units[unit]
EOF
}

last_used=`cat $state_file`
test -z "$last_used" && last_used="$used" && echo $used > $state_file
if [[ "$used" != "$last_used" ]]; then
    this_used=`echo $used-$last_used | bc` # used since last check
    if [[ -n "$(echo $this_used | grep '^-')" ]]; then
        # usage is reset
        source ~/.push
        push airtel@`hostname` "${last_used} GB internet used this month"
    fi
    this_used=`echo $this_used | sed "s/^-.*$/$used/"` # handle negative values
    this_used="$(pretty $this_used)" # pretiffy numbers
    log="$this_used used: $usage"
    echo `date`: $log >> $log_file
    echo $log
    echo $used > $state_file
fi
