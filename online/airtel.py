import sys, os
import urllib, urllib2
import cookielib
from lxml import etree
from StringIO import StringIO

user = sys.argv[1]
passwd = sys.argv[2]
phone = sys.argv[3]
acc = sys.argv[4]

cj = cookielib.CookieJar()
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))

def uopen(url, data={}):
    return opener.open(url, urllib.urlencode(data)).read()

def login(user, passwd):
    data = {
        'username': user,
        'password': passwd,
        'login-form-type': 'pwd',
    }
    try:
        s = uopen('https://airtel.in/pkmslogin.form', data)
    except urllib2.URLError:
        login(user, passwd)

def quota(phone_no, acc_no):
    try:
        s = uopen('https://www.airtel.in/myaccount/NavigationApp/jsp/unbill.jsp?no='+phone_no+'&accno='+acc_no+'&serviceType=DSL')
    except urllib2.URLError:
        return quota(phone_no, acc_no)

    s = s[s.find('url :"')+6:]
    ajax_url = s[:s.find('"')]
    s = s[s.find('data: "')+7:]
    ajax_data = s[:s.find('"')]

    try:
        s = opener.open('https://www.airtel.in'+ajax_url, ajax_data).read()
    except urllib2.URLError:
        return quota(phone_no, acc_no)

    try:
        root = etree.parse(StringIO(s), etree.XMLParser()).getroot()
        used = float(root.xpath('//unbilledDSLUsage/unbilledUsage')[0].text)
        left = float(root.xpath('//unbilledDSLUsage/gbLeft')[0].text)
        return used, left
    except IndexError:
        return quota(phone_no, acc_no)

def read_usage():
    try:
        return float(open(STATE_FILE).read())
    except IOError:
        return 0

def save_usage(used):
    open(STATE_FILE, 'w').write(str(used))

used, left = quota(phone, acc)
last_used = read_usage()
print str(used-last_used), 'GB used:', str(used)+'/'+str(int(used+left)), 'GB quota'
save_usage(used)
