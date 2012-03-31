#!/bin/sh
# Author: Kavin Parekh <kingofhearts9211@gmail.com>
#
# This script is for using internet through your personal
# device while still staying connected to your local LAN
# at workplace/school.
#
# README: Read up on route ('man route')
#         Change the targets, gateways, netmasks, etc. to suit your own setup.

# flush the routing table
route del default

# route all traffic through my datacard/phone
route add default gw 192.168.42.129 dev usb0

# route LAN traffic through my local gateway
route add -net 10.100.0.0 netmask 255.255.0.0 gw 10.100.98.4 dev eth0
