#!/usr/bin/env python2
# Author: Viranch Mehta <viranch.mehta@gmail.com>

import urllib
import time

#student ID without '@d-iict.org'
username = '200801001'

#cyberoam password
password = '200801001'

#relogin time period in minutes
tm = 60

#print various messages?
SILENT = False

while True:
    try:
        f = urllib.urlopen('http://10.100.56.55:8090/httpclient.html','mode=191&username='+username+'&password='+password)
        s = f.read()
        f.close()
        if not SILENT:
            s=s.split('message')[1][1:-2]
            print time.strftime('--%Y-%m-%d %I:%M %p--'), s+'.'
        time.sleep (tm*60)
    except IOError, error:
        if not SILENT:
            print time.strftime('--%Y-%m-%d %I:%M %p--'), str(error)

