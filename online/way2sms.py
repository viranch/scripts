# Doesn't work anymore, needs to be fixed
import sys
import time
import urllib2, cookielib

if len(sys.argv)<5:
    print 'Usage:', sys.argv[0], 'way2sms_username', 'way2sms_password', 'receiver_number', 'text_to_send'
    sys.exit(1)

cj = cookielib.CookieJar()
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
opener.addheaders = [('User-Agent','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.106 Safari/535.2')]

def login (user, passwd):
    f = opener.open('http://site5.way2sms.com/Login1.action', 'username='+user+'&password='+passwd)
    s = f.read()
    f.close()
    return 'logout' in s

def send (recvr, text):
    f = opener.open('http://site5.way2sms.com/quicksms.action', 'HiddenAction=instantsms&Action=455dasv556&MobNo='+recvr+'&textArea='+text)
    f.close()

def log (text, filename):
    f=open(filename, 'w')
    f.write(text)
    f.close()

sender = sys.argv[1]
password = sys.argv[2]
receiver = sys.argv[3]
text = ' '.join(sys.argv[4:])

print 'Logging in...',
sys.stdout.flush()
if login(sender, password):
    print 'done'
    print 'Sending text...',
    sys.stdout.flush()
    send(receiver, text)
    print 'done'
else:
    print 'Invalid username/password'
    sys.exit(2)
