date=$(timedatectl status|head -n1|awk '{print $4}')
time=$(timedatectl status|head -n1|awk '{print $5}')
h=$(echo $time|cut -d":" -f1)
m=$(echo $time|cut -d":" -f2)
s=$(echo $time|cut -d":" -f3)

h=$((h-5))
if [[ $m -lt 30 ]]; then
    h=$((h-1))
    m=0
else
    m=$((m-30))
fi

echo "sudo timedatectl set-time \"$date $h:$m:$s\""
sudo timedatectl set-time "$date $h:$m:$s"
