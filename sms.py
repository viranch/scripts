import cookielib
import urllib2
import sys

username = 'viranch'
password = 'daskapital'

cj = cookielib.CookieJar()
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))

f = opener.open("http://www.spicesms.com/sendsms.php")
s = f.read()
f.close()

s = s[s.find('cap'):]
cap = 'http://www.spicesms.com/'+s[:s.find('"')]

f = opener.open(cap)
i = open('captcha.png','wb')
i.write(f.read())
i.close()
f.close()

code = raw_input('captcha: ')

f = opener.open('http://spicesms.com/sendsms.php','mobile='+sys.argv[1]+'&message='+sys.argv[2]+'&charLeft='+str(130-len(sys.argv[2]))+'&code='+str(code)+'&Preview=Send!')
s = f.read()
f.close()

i=open('log1.html','w')
i.write(s)
i.close()

f = opener.open('http://spicesms.com/sendsms.php','Submit=Confirm%20-%20Send%20SMS&login='+username+'&pass='+password)
s = f.read()
f.close()

i=open('log2.html','w')
i.write(s)
i.close()

while True:
	st = s.find('<p align="center">')
	if st<0: break
	s=s[st+len('<p align="center">'):]
	print s[:s.find('</p>')]



