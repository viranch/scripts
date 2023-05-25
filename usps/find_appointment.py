# curl 'https://tools.usps.com/UspsToolsRestServices/rest/v2/facilityScheduleSearch' -d '{"poScheduleType":"PASSPORT","date":"20220902","numberOfAdults":"0","numberOfMinors":"1","radius":"20","zip5":"95035","city":"","state":""}' -D- -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.5089.84 Safari/537.36' --http1.1 -H 'content-type: application/json;charset=UTF-8'

import sys
import requests
from datetime import datetime, timedelta, date
from time import strftime

s = requests.Session()
s.headers['user-agent'] = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.5089.84 Safari/537.36'
s.headers['content-type'] = 'application/json;charset=UTF-8'

zips = open(sys.argv[1]).read().strip().split('\n')

day_count = 50 #(date(2023,4,30) - datetime.today().date()).days
for mydate in (datetime.today() + timedelta(n) for n in range(2, day_count, 3)):
    for code in zips:
        #print('checking', code, date)
        avail = s.post('https://tools.usps.com/UspsToolsRestServices/rest/v2/facilityScheduleSearch', json={
            'poScheduleType': 'PASSPORT',
            'date': strftime("%Y%m%d", mydate.timetuple()),
            'numberOfAdults': 0,
            'numberOfMinors': 1,
            'radius': '20',
            'zip5': str(code),
            'city': '',
            'state': '',
        }).json()

        for office in avail['facilityDetails']:
            addr = office['address']
            for ds in office['date']:
                if ds['status'] != 'false':
                    d = ds['date']
                    print(addr['addressLineOne'] + ',', addr['city'], addr['postalCode'], 'available on', d[4:6] + '/' + d[6:])
