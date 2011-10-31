sed -e "s/eth0/$2/g" -e "s/wlan0/$2/g" -e "s/ppp0/$2/g" -e "s/usb0/$2/g" -i $1/conky-arch.conf
sed -e "s/eth0/$2/g" -e "s/wlan0/$2/g" -e "s/ppp0/$2/g" -e "s/usb0/$2/g" -i $1/clock_rings.lua
