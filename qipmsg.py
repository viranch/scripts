""" Simple script for automatically adding IPs to search for in QIPMessenger. """

import os

fname = os.getenv('HOME')+'/.qipmsg/qipmsg.ini'

f = open(fname)
a = f.read()
f.close()

s = 'userSpecifiedBroadcastIp='
g = s
for i in range(88, 100):
	for j in range(1, 255):
		g += '10.100.'+str(i)+'.'+str(j)+'\\r'

f = open(fname, 'w')
f.write(a.replace(s, g))
f.close()

