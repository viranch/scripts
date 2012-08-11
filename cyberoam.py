#!/usr/bin/env python2
# Author: Viranch Mehta <viranch.mehta@gmail.com>

import sys
import urllib
import time

username = 'Mehta'
password = '1234'

#relogin time period in minutes
tm = 10

url = "http://172.16.1.1/24online/servlet/CyberoamHTTPClient"

def talk(mode):
    f = urllib.urlopen(url, 'mode='+mode+'&username='+username+'&password='+password)
    s = f.read()
    f.close()
    s = s.split('message=')[1].split('&')[0].replace('+',' ')
    print s+'.'

def login():
    print 'Logging in...',
    sys.stdout.flush()
    talk('191')

def logout():
    print '\nLogging out...',
    sys.stdout.flush()
    talk('193')

try:
    while True:
        login()
        time.sleep (tm*60)
except KeyboardInterrupt:
    logout()
