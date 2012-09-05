import sys
import urllib, urllib2
import subprocess

paste = sys.stdin.read()

f = urllib2.urlopen("http://pb/", urllib.urlencode({"name":"Viranch Mehta", "lang":"text", "code":paste, "submit":"submit"}))
url = f.url
f.close()

print url
subprocess.call(['xdg-open', url])
