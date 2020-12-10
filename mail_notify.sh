#!/bin/bash

find ~/Library/Mail/V*/*/*.mbox -newerBt '5 minute ago' -type f -name \*.emlx | /usr/local/bin/python3 $HOME/code/scripts/mail_notify.py

#[[ `find ~/Library/Mail/V*/*/Dump.mbox -type f -name \*.emlx | wc -l` -ge 1500 ]] && $HOME/bin/alerter -title "Clean up dump" -subtitle "Over 1500 messages cluttered" -message "" -appIcon /System/Applications/Mail.app/Contents/Resources/ApplicationIcon.icns -timeout 10

exit $?

function displaytime {
  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  (( $D > 0 )) && printf '%dd ' $D
  (( $H > 0 )) && printf '%dh ' $H
  (( $M > 0 )) && printf '%dm ' $M
  (( $S > 0 )) && printf '%ds\n' $S
}

function get_field() {
    /usr/local/bin/ggrep -A5 -m1 "^$2: " "$1" | /usr/local/bin/gsed ':a;N;$!ba;s/\n / /g' | head -1 | cut -d' ' -f2- | sed 's/"//g'
}

function uniq_subjects() {
    cat > /tmp/em.py << EOF
import sys
lines = sys.stdin.read().strip().split('\n')
e = {}
for line in lines:
    if not line.strip():
        continue
    em, subj, ts = line.split('^')
    ts = int(ts)
    if e.setdefault(subj, (ts, em))[0] < ts:
        e[subj] = (ts, em)
if e:
    print('\n'.join(x[1] for x in e.values()))
EOF
    /usr/local/bin/python3 /tmp/em.py
}

function notify() {
    local email="$1"
    local from=`get_field "$email" From | cut -d'<' -f1`
    local subject=`get_field "$email" Subject`
    local folder=`echo $email | grep '[^/]\+\.mbox' -o | tr "\n" "/" | sed 's/.mbox//g;s/\/$//g'`
	local now=`/usr/local/bin/gdate -u +%s`
    local sent=`/usr/local/bin/gdate -u -d "$(get_field "$email" Date)" +%s`
    [[ $((now-sent)) -gt 21600 ]] && return
    local timeago=`displaytime $((now-sent))`
    local response=`$HOME/bin/alerter -title "$from" -subtitle "\ $subject" -message "$folder ($timeago ago)" -appIcon /System/Applications/Mail.app/Contents/Resources/ApplicationIcon.icns -timeout 10`
    case $response in
        "@CONTENTCLICKED") /usr/local/bin/reattach-to-user-namespace open "$email" ;;
        "@ACTIONCLICKED") /usr/local/bin/reattach-to-user-namespace open "$email" ;;
    esac
}

#while read email; do
find ~/Library/Mail/V*/*/*.mbox -newerBt "$(/usr/local/bin/gdate -d '1 minute ago' +'%F %T')" -type f -name \*.emlx | while read email; do
    # collapse emails for the same thread into single notification from the lastest thread email
    subject=`get_field "$email" Subject | /usr/local/bin/gsed 's/^[Rr][Ee]: //g' | tr "[A-Z]" "[a-z]"`
    sent=`/usr/local/bin/gdate -u -d "$(get_field "$email" Date)" +%s`
    echo "$email^$subject^$sent"
done | tee /dev/stderr | uniq_subjects | tee /dev/stderr | sort -nrk3 -t'^' | while read email; do
    notify "$email" &
done
