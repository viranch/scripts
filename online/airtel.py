import sys
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
    s = uopen('https://airtel.in/pkmslogin.form', data)

def quota(phone_no, acc_no):
    s = uopen('https://www.airtel.in/myaccount/NavigationApp/jsp/unbill.jsp?no='+phone_no+'&accno='+acc_no+'&serviceType=DSL')
    s = s[s.find('url :"')+6:]
    ajax_url = s[:s.find('"')]
    s = s[s.find('data: "')+7:]
    ajax_data = s[:s.find('"')]

    s = opener.open('https://www.airtel.in'+ajax_url, ajax_data).read()
    root = etree.parse(StringIO(s), etree.XMLParser()).getroot()
    used = float(root.xpath('//unbilledDSLUsage/unbilledUsage')[0].text)
    left = float(root.xpath('//unbilledDSLUsage/gbLeft')[0].text)
    return used, left

done = False
while not done:
    try:
        login(user, passwd)
        used, left = quota(phone, acc)
        print str(used)+'/'+str(int(used+left)), 'GB used'
        done = True
    except:
        pass
