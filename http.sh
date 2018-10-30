#!/bin/sh
sudo /etc/rc.d/mysqld $1
sudo /etc/rc.d/httpd $1

if [ ! $1 = "start" ]; then exit 0; fi

a=$(wc -l /var/log/httpd/access_log | cut -d" " -f1)
while [ 1 ]; do
	b=$(wc -l /var/log/httpd/access_log | cut -d" " -f1)
	if [ $b -ne $a ]; then
		var=$(tail -n$((b-a)) /var/log/httpd/access_log | head -n1 | grep -v favicon | grep -v 127\.0\.0\.1)
		if [ ! -z "$var" ]; then
			ip=$(echo $var | cut -d" " -f1)
			h=$(echo $var | cut -d: -f2)
			m=$(echo $var | cut -d: -f3)
			ap="AM"
			if [ $h -gt 12 ]; then
				h=$((h-12))
				ap="PM"
			fi
			time="$h:$m $ap"
			date=$(echo $var | cut -d\[ -f2 | cut -d: -f1)
			what=$(echo $var | cut -d\" -f2)
			notify-send "Server accessed" "$ip -- $time \[$date\]\\n$what"
		fi
	fi
	a=$b
	sleep 0.5
done &

