#!/usr/bin/env python2
# Author: Viranch Mehta <viranch.mehta@gmail.com>
# API: www.imdbapi.com
# usage: imdb.py name of the movie

import urllib2
import sys
from xml.dom import minidom

title = '%20'.join(sys.argv[1:])

f=urllib2.urlopen('http://www.imdbapi.com/?t='+title+'&plot=full&tomatoes=false&r=xml')
s=f.read()
f.close()

xml = minidom.parseString(s)
movie = xml.firstChild.childNodes[0].attributes

for key in movie.keys():
    print key, ':', movie[key].value
