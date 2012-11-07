import urllib2, sys

def translate(to_translate, to_langage="auto", langage="auto"):
    '''Return the translation using google translate
    you must shortcut the langage you define (French = fr, English = en, Spanish = es, etc...)
    if you don't define anything it will detect it or use english by default
    Example:
    print(translate("salut tu vas bien?", "en"))
    hello you alright?'''
    agents = {'User-Agent':"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30)"}
    before_trans = 'class="t0">'
    link = "http://translate.google.com/m?hl=%s&sl=%s&q=%s" % (to_langage, langage, to_translate.replace(" ", "+"))
    request = urllib2.Request(link, headers=agents)
    page = urllib2.urlopen(request).read()
    page = page[page.find(before_trans)+len(before_trans):]
    results = [page.split('<')[0]]
    before_trans = '<b></b><br>'
    st = page.find(before_trans)
    if st>=0:
        page = page[page.find(before_trans)+len(before_trans):]
        results = page[:page.find('</div>')].split('<br>')
    while '' in results: results.remove('')
    while to_translate in results: results.remove(to_translate)
    return results

try: froml = sys.argv[1]
except IndexError: froml = "auto"
try: tol = sys.argv[2]
except IndexError: tol = "auto"

for i in sys.stdin.read().split("\n")[:-1]:
    print i, '>>',
    for j in translate(i, tol, froml): print j+',',
    print ''
