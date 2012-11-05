import sys
import time
import urllib2, cookielib, urllib
import getpass

if len(sys.argv)<4:
    print 'Usage:', sys.argv[0], 'username', 'receiver_number', 'text_to_send'
    sys.exit(1)

cj = cookielib.CookieJar()
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
opener.addheaders = [('User-Agent','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.106 Safari/535.2')]

def login(user, passwd):
    f = opener.open('http://ontextme.com/exchange/ajax/auth/login/', 'mobile='+user+'&password='+passwd)
    s = f.read()
    f.close()
    return 'success' in s

def exchange(s):
    ex = {}
    for name in ['exchangeId', 'exchangeToken']:
        s = s[s.find(name):]
        s = s[s.find('value="')+len('value="'):]
        ex[name] = s[:s.find('"')]
    return ex['exchangeId'], ex['exchangeToken']

def send(recvr, text):
    f = opener.open('http://ontextme.com/share')
    s = f.read()
    f.close()
    eid, etok = exchange(s)

    data = { 'exchangeId': eid, 'exchangeToken': etok, 'toMobile': recvr, 'message': text }
    f = opener.open('http://ontextme.com/exchange/ajax/validate/', urllib.urlencode(data))
    s = f.read()
    f.close()
    return s

def log (text, filename):
    f=open(filename, 'w')
    f.write(text)
    f.close()

sender = sys.argv[1]
password = getpass.getpass()
receiver = sys.argv[2]
text = ' '.join(sys.argv[3:])

print 'Logging in...',
sys.stdout.flush()
if login(sender, password):
    print 'done'
    print 'Sending text...',
    sys.stdout.flush()
    s = send(receiver, text)
    print s
else:
    print 'Invalid username/password'
    sys.exit(2)
