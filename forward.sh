# convenience script to NAT traffic on HTTP port to other destination

dest=$1
shift

ip_needs_fwd=""

if [[ `sysctl -n net.ipv4.ip_forward` == "0" ]]; then
    ip_needs_fwd="yes"
    sudo sysctl net.ipv4.ip_forward=1
fi

to=`dig +short $dest | head -n1`
for i in $@; do
    sudo iptables -t nat -A PREROUTING -p tcp --dport $i -j DNAT --to-destination $to
done
sudo iptables -t nat -A POSTROUTING -j MASQUERADE

echo "Proxying $dest ($to), press any key to stop."
read _

for i in $@; do
    sudo iptables -t nat -D PREROUTING -p tcp --dport $i -j DNAT --to-destination $to
done
sudo iptables -t nat -D POSTROUTING -j MASQUERADE

if [[ -n "ip_needs_fwd" ]]; then
    sudo sysctl net.ipv4.ip_forward=0
fi

echo "Proxy stopped."
