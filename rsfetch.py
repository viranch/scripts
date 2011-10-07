#! /usr/bin/env python
# Author: Viranch Mehta <viranch.mehta@gmail.com>
# A script to download files from rapidshare

import sys
import os
import urllib2
import time
import threading

KB = 1024
MB = 1024*1024
TIMEOUT = 180
WAIT_TIME = 130
usage = 'Usage: ./rsfetch.py -i file | ./rsfetch.py url1 [url2] [url3] ...'

class ConnectionError (Exception): pass
class FileNotFound (Exception): pass
class NoSimultaneousDownloads (Exception): pass
class DownloadLimit (Exception): pass
class Timeout (Exception): pass
class UnknownError (Exception): pass

def openurl ( url, data=None ):

	for i in range(5):
		try:
			fd = urllib2.urlopen (url, data)
			return fd
		except IOError as error:
			if i==4:
				raise ConnectionError
			continue

def get_dlpage ( uri ):

	page = openurl ( uri )
	dl_page = page.read()
	page.close()
	if 'file could not be found' in dl_page:
		raise FileNotFound
	start = dl_page.find ( 'http://rs' )
	if start<0:
		raise UnknownError
	dl_page = dl_page[start:]
	end = dl_page.find ( '\" method' )
	dl_page = dl_page[:end]
	return dl_page

def get_url ( dl_page ):

	page = openurl ( dl_page, 'dl.start=Free' )
	url = page.read()
	page.close()
	end = url.find( '\\\';\" /> Level(3) #2' )
	if end<0:
		if 'wait until the download is completed' in url:
			raise NoSimultaneousDownloads
		elif 'reached the download limit' in url:
			raise DownloadLimit
		else:
			raise UnknownError
	else:
		url = url[:end]
		url = url[::-1]
		start = url.find('ptth') + 4
		url = url[:start]
		url = url[::-1]
		return url

def format_bytes ( bytes ):

	if bytes>=MB:
		return str.format ( '{0:.2f}M', float(bytes)/MB )
	elif bytes>=1024:
		return str.format ( '{0:.2f}K', float(bytes)/1024 )
	else:
		return str.format ( '{0}b', bytes )

class InterruptableThread (threading.Thread):
	def __init__ (self, fd):
		threading.Thread.__init__(self)
		self.result = None
		self.fd = fd
	def run (self):
		self.result = self.fd.read ( KB )

def read ( fd, timeout ):
	it = InterruptableThread (fd)
	it.start ()
	it.join (timeout)
	if it.isAlive():
		return None
	else:
		return it.result

def download ( url ):

	done_size = 0
	speed = 0
	fd = openurl ( url )
	size = int ( fd.info()['Content-Length'] )
	sizestr = format_bytes (size)
	save = open ( url.split('/')[-1], 'wb' )
	start = time.time()
	while done_size<size:
		recv = read ( fd, TIMEOUT )
		if recv is None:
			save.close()
			fd.close()
			os.remove ( url.split('/')[-1] )
			raise Timeout
		elpd = time.time()-start
		sz = len ( recv )
		save.write ( recv )
		done_size = done_size + sz
		speed += sz
		progress = done_size*75/size
		percent = done_size*100/size
		print '\r Downloading ...', '[' + '='*progress + ' '*(75-progress) + ']', str(percent)+'%', 'of', sizestr, 'at', format_bytes( speed/elpd )+'/s      ',
		sys.stdout.flush()
		if elpd>10:
			start = time.time()
			speed = 0
	print ''
	fd.close()
	save.close()
	return done_size

def get ( uri ):

	print '['+uri.split('/')[-1]+']'
	print ' Fetching download URL ...',
	sys.stdout.flush()
	dl_page = get_dlpage ( uri )
	while True:
		try:
			url = get_url ( dl_page )
			print 'Done. [', url, ']'
			break
		except DownloadLimit:
			print 'Download limit reached for free-user. File will be available after few minutes.'
		except NoSimultaneousDownloads:
			print 'Another download is in progress. Retry after that download is complete.'
		print '  Retrying after 1 min...',
		sys.stdout.flush()
		time.sleep ( 60 )
		print '\r Fetching download URL ...',
		sys.stdout.flush()
	for j in range (WAIT_TIME, 0, -1):
		print '\r  Download will start in', str(j), 'seconds. ',
		sys.stdout.flush()
		time.sleep ( 1 )
	print '\r Downloading ...', ' '*20, '\b'*20,
	sys.stdout.flush()
	size = download ( url )
	print ' Download complete.'

def main():

	if not len(sys.argv)>1:
		print usage
		return None
	if '-i' in sys.argv[1]:
		links = open ( sys.argv[2], 'r' )
		uri_list = links.read().split('\n')
		links.close()
		uri_list = uri_list + sys.argv[3:]
	else:
		uri_list = sys.argv[1:]
	for uri in uri_list:
		if 'http:' in uri:
			print time.strftime('--%I:%M %P--')
			try:
				get ( uri.replace(' ','') )
			except ConnectionError:
				print 'Could not connect to server.'
			except FileNotFound:
				print 'File does not exist on server.'
			except Timeout:
				print '\nConnection Timed out.'
			except UnknownError:
				print 'Unknown error.'
			print time.strftime('--%I:%M %P--\n')

if __name__ == '__main__':
	main()
