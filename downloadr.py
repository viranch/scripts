# Usage:
#        python2 downloadr.py --tag USER TAGS
#        python2 downloadr.py --set HTTP_LINK_TO_SET
#        python2 downloadr.py --collection HTTP_LINK_TO_COLLECTION
#        python2 downloadr.py --search SEARCH_STRING

import os, sys
import urllib
import subprocess

class Downloadr:
    cmd = ['swget', '-q', '-nc', '--max-redirect=0']

    def do(self, link):
        s = urllib.urlopen(link).read()
        html = s
        s = s[s.find(self.token):]
        original = True
        while True:
            st = s.find('img src="http://farm')
            if st<0: break
            s = s[st+len('img src="'):]
            l = s[:s.find('"')].replace(self.suffix, '_o')
            if 'buddyicons' in l: continue
            name = l.split('/')[-1]
            if not os.access ( name, os.F_OK ):
                if original:
                    subprocess.call ( self.cmd + [l] )
                if not os.access(name, os.F_OK):
                    original = False
                    l = l.replace('_o', '_b')
                    name = l.split('/')[-1]
                    if not os.access(name, os.F_OK):
                        subprocess.call ( self.cmd + [l] )
                        print name
                else:
                    print name
        return html

    def download (self):
        if not os.path.isdir(self.dirname): os.makedirs(self.dirname)
        os.chdir(self.dirname)
        print 'Downloading photos to "' + self.dirname + '" ...'

        pages = 1
        print 'Page 1'
        s = self.do(self.rootLink+'1')

        while True:
            st = s.find(self.pageToken)
            if st<0: break
            s = s[st+len(self.pageToken):]
            pages = max(pages, int(s[0]))

        for i in range(2, pages+1):
            print 'Page', i
            self.do(self.rootLink + str(i))

        os.chdir('..')

    def debug(self):
        print self.token, self.suffix, self.rootLink, self.pageToken, self.dirname

class tagDownloadr (Downloadr):
    token = 'GoodStuff'
    suffix = '_t'
    pageToken = '/page'

    def __init__(self, user, tags):
        self.rootLink = 'http://www.flickr.com/photos/'+user+'/tags/'+tags+'/page'
        self.dirname = tags+' by '+user

class setDownloadr (Downloadr):
    token = 'setThumbs'
    suffix = '_s'
    pageToken = 'page='

    def __init__ (self, setLink):
        self.rootLink = setLink + '/?page='
        s = urllib.urlopen(self.rootLink+'1').read()
        s = s[s.find('<title>')+7:]
        user = setLink.replace('http://www.flickr.com/photos/', '')
        self.dirname = s[:s.find(' - a set on Flickr</title>')]+' by '+user[:user.find('/')]

    def setSetLink (self, link): self.__init__(link)

class collectionDownloadr:
    def __init__ (self, collLink):
        self.link = collLink
        self.obj = setDownloadr('')

    def download(self):
        s = urllib.urlopen(self.link).read()
        while True:
            st = s.find('Seta')
            if st<0: break
            s = s[st+12:]
            self.obj.setSetLink( 'http://www.flickr.com'+s[:s.find('"')] )
            s = s[s.find('title')+7:]
            title = s[:s.find('"')].replace('&amp;', '&')
            print title
            self.obj.dirname = self.obj.dirname + '/' + title
            self.obj.download()
            os.chdir('..')

class searchDownloadr (Downloadr):
    token = 'ResultsThumbs'
    suffix = '_t'
    pageToken = 'page='

    def __init__ (self, searchStr):
        self.rootLink = 'http://www.flickr.com/search/?q='+searchStr+'&page='
        self.dirname = searchStr

if sys.argv[1]=='--tag':
    user = sys.argv[2]
    tags = sys.argv[3]
    obj = tagDownloadr(sys.argv[2], sys.argv[3])
elif sys.argv[1]=='--set':
    obj = setDownloadr(sys.argv[2])
elif sys.argv[1]=='--collection':
    obj = collectionDownloadr(sys.argv[2])
elif sys.argv[1]=='--search':
    obj = searchDownloadr (sys.argv[2])

#obj.debug()
obj.download()

