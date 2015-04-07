# convenience script to NAT traffic on HTTP port to other destination

to=`dig +short $1 | head -n1`
shift

sudo sysctl net.ipv4.ip_forward=1
for i in $@; do
    sudo iptables -t nat -A PREROUTING -p tcp --dport $i -j DNAT --to-destination $to
done
sudo iptables -t nat -A POSTROUTING -j MASQUERADE

echo "Proxying $1, press any key to stop. "
read _

sudo sysctl net.ipv4.ip_forward=0
for i in $@; do
    sudo iptables -t nat -D PREROUTING -p tcp --dport $i -j DNAT --to-destination $to
done
sudo iptables -t nat -D POSTROUTING -j MASQUERADE

echo "Proxy stopped."
