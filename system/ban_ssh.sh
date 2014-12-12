TODAY=`date +%F`
ALL="/tmp/all.$TODAY"
GOOD="/tmp/good.$TODAY"

conn_str="Connection from "
green_str="Accepted publickey for "

# fetch today's logs
sudo journalctl -u sshd --since today > $ALL

# filter out nice people
grep -e "$conn_str" -e "$green_str" $ALL | grep -B1 "$green_str" | grep "$conn_str" | cut -d' ' -f8 | sort -u > $GOOD

# list all evil
grep "$conn_str" $ALL | cut -d' ' -f8 | grep -v -f $GOOD | uniq -c | grep -v "^[^0-9]*[0-9] " | \
    # block all evil not already blocked
    awk '{print $2}' | while read ip; do test -z "`sudo iptables -nL | grep $ip`" && echo iptables -A INPUT -s $ip -j DROP; done
