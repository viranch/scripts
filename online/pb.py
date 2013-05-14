import sys
import urllib, urllib2
import subprocess

sys.argv.append("text")

paste = sys.stdin.read()
lang = sys.argv[1]

f = urllib2.urlopen("http://pb/", urllib.urlencode({"name":"Viranch Mehta", "lang":lang, "code":paste, "submit":"submit"}))
url = f.url
f.close()

print url
try:
    from PyQt4.QtCore import QUrl
    from PyQt4.QtGui import QDesktopServices
    QDesktopServices.openUrl(QUrl(url))
except ImportError:
    try:
        subprocess.call(['xdg-open', url])
    except OSError:
        pass
