# Doesn't work anymore, needs to be fixed
import sys
import time
import re, random
import urllib, urlparse
import urllib2, cookielib

if len(sys.argv)<5:
    print 'Usage:', sys.argv[0], 'way2sms_username', 'way2sms_password', 'receiver_number', 'text_to_send'
    sys.exit(1)

way2sms = 'site'+str(random.randint(1, 12))+'.way2sms.com'

cj = cookielib.CookieJar()
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
opener.addheaders = [('User-Agent','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.106 Safari/535.2'), ('Host',way2sms), ('Origin','http://'+way2sms)]

grep = re.compile('<input [^>]*>')

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
    data = { 'kriya':'455dasv556', 'catnamedis':'', 'diffNo':'', 't_15_k_5':'', 'm_15_b':'' }
    params_url = 'http://'+way2sms+'/jsp/SingleSMS.jsp?Token='+session_id
    f = uopen(params_url)
    s = f.read()
    f.close()
    open('log.html','w').write(s)
    for i in grep.findall(s):
        name = parseTag(i, 'name')
        if name in data.keys(): data[name] = parseTag(i, 'value')
    data['i_m'] = 'sn2sms'
    data[data['m_15_b']] = recvr
    data[data['t_15_k_5']] = session_id
    data['textArea'] = text
    data['txtLen'] = 140-len(text)
    data['chkall'] = 'on'
    s = s[s.find('"name", "')+len('"name", "'):]
    data[s[:s.find('"')]] = ''
    print data
    opener.addheaders.append(('Referer',params_url))
    f = uopen('http://'+way2sms+'/jsp/w2ssms.action', data)
    s = f.read()
    f.close()
    print f.url

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
