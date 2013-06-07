import urllib2
from StringIO import StringIO
from lxml import etree
import sys, os
import subprocess

hp = etree.HTMLParser()

def jpg_link(link):
    name, wid, res = link.rsplit('/', 4)[-4:-1]
    jpg = '-'.join([name, res, wid]) + '.jpg'
    return '/'.join(['http://wallpapers.skins.be', name, jpg])

def parse_page(src):
    doc = etree.parse(src, hp).getroot()
    links = []
    for wp in doc.xpath('//ul[@class="resolutionListing"]'):
        pages = wp.xpath('li')[-1].xpath('a/@href')
        links += [jpg_link(p) for p in pages]
    return links

def download(dirpath, links):
    if links == []: return
    pwd = os.getcwd()
    if not os.path.exists(dirpath): os.makedirs(dirpath)
    os.chdir(dirpath)
    subprocess.call(['wget', '-nc', '--max-redirect=0'] + links)
    os.chdir(pwd)

print 'Getting everone...'
doc = etree.parse('http://www.skins.be/babes', hp).getroot()
for model in doc.xpath('//div[@class="box"]/a'):
    name = model.text.strip()
    print name
    page = model.get('href') + 'wallpapers'
    s = urllib2.urlopen(page).read()
    links = []
    root = etree.parse(StringIO(s), hp).getroot()
    for page in [StringIO(s)] + root.xpath('//div[@id="pagination"]/a/@href')[:-2]:
        links += parse_page(page)
    download(sys.argv[1]+'/'+name, links)
