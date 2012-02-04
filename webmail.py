#!/usr/bin/env python2
# Author: Viranch Mehta <viranch.mehta@gmail.com>

import sys, getpass
import urllib2
import cookielib
import HTMLParser

if len(sys.argv)<2:
    username = raw_input('Username: ')
else:
    username = sys.argv[1]

def make_cookie(ck_name, ck_value):
    return cookielib.Cookie(version=0, name=ck_name, value=ck_value, port=None, port_specified=False, domain='webmail.daiict.ac.in', domain_specified=False, domain_initial_dot=False, path='/', path_specified=True, secure=False, expires=None, discard=True, comment=None, comment_url=None, rest={'HttpOnly': None}, rfc2109=False)

cj = cookielib.CookieJar()
cj.set_cookie(make_cookie("ZM_TEST", "true"))
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
opener.addheaders = [('Host','webmail.daiict.ac.in'),
                     ('User-Agent','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.77 Safari/535.7')]

test_string  = '<b>Mobile</b> is recommended for mobile devices. <br><br>To set <b>Default</b> to be your preferred client type, change the login options in your Preferences, General tab after you log in.</div>'
while True:
    password = getpass.getpass()
    f = opener.open('http://webmail.daiict.ac.in/zimbra/?loginOp=login&username='+username+'&password='+password+'&client=standard')
    s = f.read()
    f.close()
    if test_string not in s: break
    print 'Sorry, try again.'

def parse(s, start, end):
    s = s[s.find(start)+len(start):]
    return HTMLParser.HTMLParser().unescape(s[:s.find(end)])

print ''
while True:
    st = s.find('<span title=')
    if st<0: break
    s = s[st+1:]
    folder = s[s.find('>')+1:s.find('<')]
    if '(' in folder:
        tok = folder.split('\n')
        name = tok[0]
        count = tok[1]
        count = count[count.find('(')+1:count.find(')')]
        print count, 'unread email(s) in', name

emails = []
while True:
    st = s.find('<tr onclick')
    if st<0: break
    s = s[st+1:]
    cl = parse(s, 'class=\'', '\'')
    if 'Unread' not in cl: continue
    sender = parse(s, '<td>', '\n')
    subj = parse(s, '<span class="Fragment">', '</span>')
    frag = parse(s, '<span class=\'Fragment\'>', '</span>')
    when = parse(s, '<td nowrap align="right">\n\t\t\t\t\t\t\t\t\t', '\n')
    emails.append([sender, subj, when, frag])

if len(emails)>0: print '\n', 'Inbox:'
for email in emails:
    print 'From:', email[0]
    print 'Subject:', email[1]
    print 'Received:', email[2]
    print email[3]
    print ''

