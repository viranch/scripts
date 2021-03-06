#!/usr/bin/env python2
# Usage: skins-dl
#    or: skins-dl http://wallpaper.skins.be/model-name/id/res.html ... ...
# Downloads new wallpapers

import urllib2
import sys
import os
import shutil
import subprocess
from lxml import etree

HOME = os.getenv("HOME")
ROOT = HOME+'/Pictures/Wallpapers'
DB = ROOT+'/Skins.be/'
DB_SELECTED = ROOT+'/Selected/'

WEB = 'http://www.skins.be'
url_list = []
CONF = HOME+'/.skins.conf'

def ask(question):
    while True:
        ch = raw_input(question)
        if ch=='n' or ch=='N': return false
        if ch=='': return true

def parse(link):
    tokens = link.split('/')
    return tokens[-4], tokens[-3], tokens[-2]

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
    name, wid, res = parse(page)
    filename = '-'.join([name,res,wid]) + '.jpg'
    url = '/'.join(['http://wallpapers.skins.be', name, filename])
    return url

def get_updates(page=1):
    last = read_last()
    print 'Page ' + str(page) + ',',
    sys.stdout.flush()
    f = urllib2.urlopen('/'.join([WEB, 'page', str(page)]))
    doc = etree.parse(f, etree.HTMLParser()).getroot()
    for wp in doc.xpath('//ul[@class="resolutionListing"]'):
        page = wp.xpath('li')[-1].xpath('a/@href')[0]
        url = get_url(page)
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
        if not ask(' Skins.be/' + dirname + fname + ' exists. Overwrite? [Y/n] '):
            return None
    
    if move:
        shutil.move(fname, DB+dirname+fname)
        print '', fname, 'moved to database'
    else:
        shutil.copyfile(fname, DB + dirname + fname)
        print '', fname, 'copied to database'

def main():
    print 'Looking up for new wallpapers...',
    sys.stdout.flush()
    get_updates()
    print len(url_list), 'found.'

    if url_list == []: return

    print 'Downloading...'
    subprocess.call(['wget', '-nc', '--max-redirect=0'] + url_list)
    write_last(url_list[0])
    raw_input('Copy to the database? ')
    selected=[]
    for url in url_list:
        try:
            fname = url.split('/')[-1]
            isSelected = os.access(DB_SELECTED+getdirname(fname), os.F_OK)
            if isSelected: selected.append(url)
            copy_to_database(fname, not isSelected)
        except IOError as error:
            print str(error)
    if len(selected)>0:
        raw_input('\nCopy to the selected wallpapers? ')
    for url in selected:
        try:
            copy_to_selected(url.split('/')[-1])
        except IOError as error:
            print str(error)

if __name__=='__main__':
    main()
