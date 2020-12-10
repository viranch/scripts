import sys
import requests
from ratelimit import limits, sleep_and_retry

airtable = requests.Session()

@sleep_and_retry
@limits(calls=5, period=1)
def call_at(method, url, params=None, data=None):
    if data:
        return airtable.request(method, url, json={'fields': data, 'typecast': True}, headers={'Authorization': os.environ['api_key'], 'Content-Type': 'application/json'}, params=params).json()
    else:
        return airtable.request(method, url, headers={'Authorization': os.environ['api_key'], 'Content-Type': 'application/json'}, params=params).json()

offset = None
sheet = sys.argv[1]
table = sys.argv[2]
while True:
    r = call_at('GET', f'https://api.airtable.com/v0/{sheet}/{table}', params={'offset': offset, 'view': 'Grid view'})
    rows = r['records']

    for row in rows:
        car = row['fields']['VehicleDescription']
        photo_url = row['fields']['VehiclePicture']
        if photo_url == 'N/A' or len(row['fields'].get('Photo', [])) > 0:
            print(f'Skipping {car}')
            continue
        print(car)
        row_id = row['id']
        call_at('PATCH', f'https://api.airtable.com/v0/{sheet}/{table}/{row_id}', data={'Photo':[{'url': photo_url}]})

    if 'offset' in r:
        offset = r['offset']
    else:
        break
