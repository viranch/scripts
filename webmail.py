import sys, getpass
import urllib2
import cookielib

username = sys.argv[1]
password = getpass.getpass()

cj = cookielib.CookieJar()
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
opener.addheaders = [('User-Agent','Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.77 Safari/535.7'),
                     ('Host','webmail.daiict.ac.in'),
                     ('Origin','https://webmail.daiict.ac.in'),
                     ('Referer','https://webmail.daiict.ac.in/zimbra/?zinitmode=http'),
                     ('Content-Type','application/x-www-form-urlencoded'),
                     ('Cookie','ZM_TEST=true; JSESSIONID=1ce4g8lu4cp2q')]

opener.open('https://webmail.daiict.ac.in/zimbra/?zinitmode=http','loginOp=login&username='+username+'&password='+password+'&client=standard').close()

opener.addheaders = opener.addheaders[:2]
f = opener.open('http://webmail.daiict.ac.in/zimbra/h/search?mesg=welcome&initial=true&app=')
s = f.read()
f.close()

# FIXME: logout request does not return proper 302, as expected
#opener.addheaders.append( ('Referer','http://webmail.daiict.ac.in/zimbra/h/search?mesg=welcome&initial=true&app=') )
#opener.open('http://webmail.daiict.ac.in/zimbra/?loginOp=logout').close()

def parse(s, start, end):
    s = s[s.find(start)+len(start):]
    return s[:s.find(end)]

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
    print 'From:', sender
    print 'Subject:', subj
    print 'Received:', when
    print frag
    print ''

