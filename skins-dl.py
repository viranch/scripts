#!/usr/bin/env python2
# Usage: skins-dl
#    or: skins-dl http://wallpaper.skins.be/model-name/id/res.html ... ...
# Downloads new wallpapers

import urllib2
import sys
import os
import shutil
import subprocess

ROOT = '$HOME/Pictures/Wallpapers'
DB = ROOT+'/Skins.be/'
DB_SELECTED = ROOT+'/Selected/'

WEB = 'http://www.skins.be/'
RSS = 'http://www.skins.be/feeds/en/skins.xml'
PROXY = 0
RES = '-1920x1200-'
url_list = []
CONF = os.getenv("HOME")+'/.skins.conf'

def proxify(link):
    if PROXY:
        link = link.replace('http:/', 'https://www.suresome.com/proxy/nph-secure/00A/http')
    return link

def parse(link):
    tokens = link.split('/')
    return tokens[-4], tokens[-3]

def read_last():
    try:
        conf = open(CONF, 'r')
        last = conf.read()
        conf.close()
    except IOError:
        last = ''
    return last

def write_last(last):
    conf = open(CONF, 'w')
    conf.write(last)
    conf.close()

def get_url(page):
    name, id = parse(page)
    url = 'http://wallpapers.skins.be/'+name+'/'+name+RES+id+'.jpg'
    return url

def get_updates(page=1):
    last = read_last()
    print ' Page' + str(page) + ',',
    sys.stdout.flush()
    f = urllib2.urlopen(proxify(WEB+'/page/'+str(page)))
    s = f.read()
    f.close()
    while True:
        st = s.find('motiveImage')
        if st<0: break
        s = s[st:]
        s = s[s.find(' href="')+7:]
        url = get_url(s[:s.find('"')])
        if url==last: break
        url_list.append(url)
    if url!=last: get_updates(page+1)

def getdirname(fname):
    nametok = fname.split('-')[:-2]
    for i in range(len(nametok)):
        nametok[i] = nametok[i].capitalize()
    return ' '.join(nametok) + '/'

def copy_to_selected(fname):
    dirname = getdirname(fname)
    shutil.move(fname, DB_SELECTED+dirname+fname)
    print '', fname, 'moved to selected wallpapers'

def copy_to_database(fname, move=False):
    dirname = getdirname(fname)

    if not os.access(DB + dirname, os.F_OK):
        ls = os.listdir(DB)
        name = '-'.join(fname.split('-')[:-2])
        flag = False
        for item in ls:
            if '.jpg' not in item:
                continue
            if item.startswith(name):
                os.mkdir(DB + dirname)
                print ' Directory', dirname[:-1], 'created'
                flag = True
                shutil.move(DB + item, DB + dirname + item)
                print '', item, 'moved to database'
                break
        if not flag:
            dirname = ''

    if os.getcwd()+'/' == DB+dirname:
        print '', fname, 'already in the database'
        return None

    if os.access(DB + dirname + fname, os.F_OK):
        ch = raw_input(' Skins.be/' + dirname + fname + ' exists. Overwrite? [Y/n] ')
        if ch=='n' or ch=='N':
            return None
    
    if move:
        shutil.move(fname, DB+dirname+fname)
        print '', fname, 'moved to database'
    else:
        shutil.copyfile(fname, DB + dirname + fname)
        print '', fname, 'copied to database'

def main():
    rss = True
    print_uris = False
    total_size = 0
    if '-p' in sys.argv:
        print_uris = True
    for arg in sys.argv[1:]:
        if arg[0]!='-':
            rss = False
            url_list.append(get_url(arg))
    if rss:
        print 'Looking up for new wallpapers ... ',
        sys.stdout.flush()
        get_updates()
        print len(url_list), 'found.'

    if len(url_list)>0 and not print_uris:
        print 'Downloading...'

    for i in range(len(url_list)):
        if print_uris:
            print url_list[i]

    if len(url_list)>0:
        subprocess.call(['wget', '-nc', '--max-redirect=0'] + url_list)

    if len(url_list)>0 and not print_uris:
        if rss:
            write_last(url_list[0])
        ch = raw_input('Copy to the database? ')
        selected=[]
        for url in url_list:
            try:
                fname = url.split('/')[-1]
                isSelected = os.access(DB_SELECTED+getdirname(fname), os.F_OK)
                if isSelected: selected.append(url)
                copy_to_database(fname, not isSelected)
            except IOError as error:
                print str(error)
        if len(selected)>0: ch = raw_input('\nCopy to the selected wallpapers? ')
        for url in selected:
            try:
                copy_to_selected(url.split('/')[-1])
            except IOError as error:
                print str(error)

if __name__=='__main__':
    main()
