# Script to reduce bit rate of mp3 files to 128 kbps
# Usage:
# ./reduce_mp3_bitrate.py <input_directory> <output directory>
#
# Eg: ./reduce_mp3_bitrate.py ~/Music/English/Akon/ /tmp
# will reduce bitrate of all mp3s in "Akon" directory and saved in /tmp/Akon

import os
import sys
import subprocess

in_dir = sys.argv[1]
out_dir = sys.argv[2]

tok = in_dir.split('/')
if tok[-1]=='': dirname = tok[-2]
else: dirname = tok[-1]
out_dir += '/'+dirname
os.makedirs (out_dir)

f=open('/tmp/reduce.sh', 'w')
f.write('lame --decode "$1" - | lame -b 128 - "$2"\n')
f.close()

for i in os.listdir (in_dir):
    if '.mp3' not in i: continue
    print i, '==>'
    subprocess.call (['sh', '/tmp/reduce.sh', in_dir+'/'+i, out_dir+'/'+i])
    print ''

os.remove ('/tmp/reduce.sh')

