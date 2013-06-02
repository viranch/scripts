import urllib2
from StringIO import StringIO
from lxml import etree

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

doc = etree.parse('http://www.skins.be/babes', hp).getroot()
for model in doc.xpath('//div[@class="box"]/a'):
    name = model.text.strip()
    page = model.get('href') + 'wallpapers'
    f = urllib2.urlopen(page)
    s = f.read()
    f.close()
    links = []
    root = etree.parse(StringIO(s), hp).getroot()
    for page in [StringIO(s)] + root.xpath('//div[@id="pagination"]/a/@href')[:-2]:
        links += parse_page(page)
    # mkdir,cd(name)
    # wget links
