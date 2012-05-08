# Script that does something with downloading mediafire
# stuff using wget

import urllib2
import sys
import subprocess

print 'Looking for download page...',
sys.stdout.flush()
f=urllib2.urlopen(sys.argv[1])
s=f.read()
f.close()

s = s[s.find('http://www.mediafire'):]
link = s[:s.find("'")]
print link

tok = link.split('?')[-1]

print 'Looking for download link...',
sys.stdout.flush()
f=urllib2.urlopen(link)
s=f.read()
f.close()

while True:
    s = s[s.find("href=\"")+len("href=\""):]
    link = s[:s.find("\"")]
    if '/'+tok in link: break
print link

print 'Downloading...'
subprocess.call(['wget', '--read-timeout=10', '-c', link])
