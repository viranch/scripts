#!/bin/sh
#
# Script to use facebook chat client over your datacard
# if jabber is blocked at your school/workplace
#
# Run as root

route add -host chat.facebook.com gw 192.168.42.129
