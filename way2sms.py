# Doesn't work anymore, needs to be fixed
import sys
import random
import urllib, urlparse
import urllib2, cookielib
from lxml import etree
from StringIO import StringIO

if len(sys.argv)<5:
    print 'Usage:', sys.argv[0], 'way2sms_username', 'way2sms_password', 'receiver_number', 'text_to_send'
    sys.exit(1)

way2sms = 'site'+str(random.randint(1, 12))+'.way2sms.com'

cj = cookielib.CookieJar()
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
opener.addheaders = [('User-Agent','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.93 Safari/537.36'), ('Host',way2sms), ('Origin','http://'+way2sms)]

def uopen(url, data={}):
    return opener.open(url, urllib.urlencode(data))

def login (user, passwd):
    data = {
        'username': user,
        'password': passwd,
        'userLogin': 'no',
    }
    f = uopen('http://'+way2sms+'/w2sauth.action', data)
    s = f.read()
    f.close()
    return urlparse.parse_qs(urlparse.urlparse(f.url).query)['id'][0]

def parseTag(tag, attr):
    attr_str = ' '+attr+'='
    n = tag.find(attr_str)
    if n<0: return None
    tag = tag[n+len(attr_str):]
    q, tag = tag[0], tag[1:]
    return tag[:tag.find(q)]

def send (recvr, text, session_id):
    s, data = post_data(recvr, text, session_id)
    data['chkall'] = 'on'
    s = s[s.find('"name", "')+len('"name", "'):]
    data[s[:s.find('"')]] = ''
    print data
    print urllib.urlencode(data)
    opener.addheaders.append(('Referer','http://'+way2sms+'/jsp/SingleSMS.jsp?Token='+session_id))
    f = uopen('http://'+way2sms+'/jsp/w2ssms.action', data)
    s = f.read()
    f.close()
    print f.url

def post_data(recvr, text, session_id):
    data = {}
    params_url = 'http://'+way2sms+'/jsp/SingleSMS.jsp?Token='+session_id
    f = uopen(params_url)
    s = f.read()
    f.close()
    open('log.html','w').write(s)
    root = etree.parse(StringIO(s), etree.HTMLParser()).getroot()
    for i in root.xpath('//html/body/form//input'):
        if i.get('type') not in ['hidden', 'text']: continue
        data[i.get('name')] = i.get('value')
    for i in root.xpath('//html/body/form/textarea'):
        data[i.get('name')] = i.text
    data[data['m_15_b']] = recvr
    data[data['t_15_k_5']] = session_id
    data['textArea'] = text
    data['txtLen'] = 140-len(text)
    data.pop('textfield2')
    return s, data

sender = sys.argv[1]
password = sys.argv[2]
receiver = sys.argv[3]
text = ' '.join(sys.argv[4:])

print 'Logging in...',
sys.stdout.flush()
sid = login(sender, password)
print 'done'
print 'Sending text...',
sys.stdout.flush()
send(receiver, text, sid)
print 'done'

#else:
#    print 'Invalid username/password'
#    sys.exit(2)
