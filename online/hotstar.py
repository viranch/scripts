import sys
import urllib2
import json

show_id = sys.argv[1]

url = 'http://search.hotstar.com/AVS/besc?action=SearchContents&appVersion=5.0.13&channel=PCTV&maxResult=999&moreFilters=series:'+show_id+'%3B&query=*&searchOrder=last_broadcast_date+asc,year+asc,title+asc&type=EPISODE'
f = urllib2.urlopen(url)
s = f.read()
f.close()

episodes = json.loads(s)['resultObj']['response']['docs']

for x in range(len(episodes)):
    episode_data = episodes[x]
    episode_data['episodeNumber'] = x + 1
    print str(episode_data['episodeNumber']).zfill(3), 'http://www.hotstar.com/tv/foo/0/bar/'+str(episode_data['contentId'])
