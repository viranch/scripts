import sys, os
import urllib, urllib2
import cookielib
from lxml import etree
from StringIO import StringIO

user = sys.argv[1]
passwd = sys.argv[2]
phone = sys.argv[3]
acc = sys.argv[4]

STATE_FILE = os.getenv('HOME')+'/.airtel.quota'
MAX_RETRIES = 10

cj = cookielib.CookieJar()
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
urllib2.install_opener(opener)

def uopen(url, data={}, encode_data=True):
    if encode_data: data = urllib.urlencode(data)
    s = urllib2.urlopen(url, data).read()
    #for ck in cj: print ck
    return s

def login(user, passwd, retry=0):
    data = {
        'username': user,
        'password': passwd,
        'login-form-type': 'pwd',
    }
    try:
        s = uopen('https://www.airtel.in/pkmslogin.form', data)
    except urllib2.URLError:
        if retry == MAX_RETRIES: sys.exit(1)
        login(user, passwd, retry+1)

def quota(phone_no, acc_no, retry=0):
    try:
        s = uopen('https://www.airtel.in/myaccount/NavigationApp/jsp/unbill.jsp?no='+phone_no+'&accno='+acc_no+'&serviceType=DSL')
    except urllib2.URLError:
        if retry == MAX_RETRIES: sys.exit(1)
        return quota(phone_no, acc_no, retry+1)

    s = s[s.find('url :"')+6:]
    ajax_url = s[:s.find('"')]
    s = s[s.find('data: "')+7:]
    ajax_data = s[:s.find('"')]

    try:
        s = uopen('https://www.airtel.in'+ajax_url.replace(' ','%20'), ajax_data, False)
    except urllib2.URLError:
        if retry == MAX_RETRIES: sys.exit(1)
        return quota(phone_no, acc_no, retry+1)

    try:
        root = etree.parse(StringIO(s), etree.XMLParser()).getroot()
        used = float(root.xpath('//unbilledDSLUsage/unbilledUsage')[0].text)
        left = float(root.xpath('//unbilledDSLUsage/gbLeft')[0].text)
        return used, left
    except (IndexError, etree.XMLSyntaxError):
        if retry == MAX_RETRIES: sys.exit(1)
        return quota(phone_no, acc_no, retry+1)

def read_usage():
    try:
        return float(open(STATE_FILE).read())
    except IOError:
        return 0

def save_usage(used):
    open(STATE_FILE, 'w').write(str(used))

login(user, passwd)
used, left = quota(phone, acc)
last_used = read_usage()
print str(used-last_used), 'GB used:', str(used)+'/'+str(int(used+left)), 'GB quota'
save_usage(used)
