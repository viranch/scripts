import sys
import urllib2
from StringIO import StringIO
from lxml import etree
from threading import Thread
from Queue import Queue

hp = etree.HTMLParser()
q = Queue()
r = Queue()

def worker():
    while True:
        try:
            url = q.get()
            request = urllib2.Request(url, headers={"Cookie": "client=linkedin; JSESSIONID=B478FD11B6D558E2BDE1562EE7E9C6AA; GloboBalancerSSL=444737034.48129.0000"})
            r.put(urllib2.urlopen(request).read())
            q.task_done()
        except:
            pass

num_workers = 10

for x in range(num_workers):
    t = Thread(target=worker)
    t.daemon = True
    t.start()

for pageno in range(1, 23):
    q.put('https://www.globoforce.net/microsites/t/redeem/rewardSubcategories?selectedCategoryID=151&selectedPage={}'.format(pageno))

while True:
    f = StringIO(r.get())
    doc = etree.parse(f, hp).getroot()
    items = doc.xpath('//div[contains(@class,"widgetItem")]/@id')
    images = doc.xpath('//div[contains(@class,"widgetItem")]//span[@class="gf-hidden"]/text()')
    points = doc.xpath('//div[contains(@class,"widgetItem")]//div[@class="pricePanel row"]/a/text()')
    for item, img, price in zip(items, images, points):
        price = int(price.split()[0])
        if price > 1690:
            continue
        print 'https://www.globoforce.net/microsites/t/redeem/RedeemItemDetails?product={}'.format(item.split('_')[-1]), img
        sys.stdout.flush()
