sed -e "s/eth/$2/g" -e "s/wlan/$2/g" -e "s/ppp/$2/g" -e "s/usb/$2/g" -i $1/conky-arch.conf
sed -e "s/eth/$2/g" -e "s/wlan/$2/g" -e "s/ppp/$2/g" -e "s/usb/$2/g" -i $1/clock_rings.lua
