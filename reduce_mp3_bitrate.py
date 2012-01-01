# Script to reduce bit rate of mp3 files to 128 kbps
# Usage:
# ./reduce_mp3_bitrate.py <input_directory> <output directory>
#
# Eg: ./reduce_mp3_bitrate.py ~/Music/English/Akon/ /tmp
# will reduce bitrate of all mp3s in "Akon" directory and saved in /tmp/Akon

import os
import sys
import subprocess

BIT_RATE = 128

in_dir = sys.argv[1]
out_dir = sys.argv[2]
if in_dir.endswith('/'): in_dir = in_dir[:-1]
root_path = in_dir.replace('/'+os.path.basename(in_dir), '')

# Returns '/tmp/Music/English/Akon' from '/home/viranch/data/Music/English/Akon'
def get_dest(srcpath):
    return srcpath.replace(root_path, out_dir+'/')

def convert(path):
    dest=get_dest(path)
    try: os.makedirs(dest)
    except: pass
    for i in os.listdir(path):
        src=path+'/'+i
        if '.mp3' in i:
            target=dest+'/'+i
            print src, '==>', target
            subprocess.call(['lame', '-F', '-b', str(BIT_RATE), src, target])
            print ''
        elif os.path.isdir(src):
            convert(src)

convert(in_dir)
