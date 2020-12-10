import os
import traceback
import requests
import json

session = requests.Session()
session.headers.update({'Content-Type': 'application/json', 'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36'})

def _call(url, params=None, json_data=None):
    if json_data:
        s = session.post(url, params=params, json=json_data)
    else:
        s = session.get(url, params=params)
    try:
        return s.json()
    except json.decoder.JSONDecodeError:
        print(s.text)

def login(username, password):
    s = _call('https://www.instacart.com/v3/dynamic_data/authenticate/login', json_data={
        "scope": "",
        "grant_type": "password",
        "signup_v3_endpoints_web": None,
        "email": username,
        "password": password,
        "address": None
    })
    if s['status'] != 'ok':
        raise Exception(s['meta']['data']['dynamic_data'])

def get_delivery_slots():
    s = _call('https://www.instacart.com/v3/retailers/5/delivery_options', params={
        'source': 'web',
        'cache_key': '5719d9-3294-f-566',
        'cart_updated_at': '1586628143.2154',
        'address_id': '100376757'
    })
    return s['service_options'].get('error_module', {}).get('title') != 'No delivery times available'

def logout():
    session.get('https://www.instacart.com/accounts/logout', allow_redirects=False)

msg = None
try:
    login(os.environ['username'], os.environ['password'])
    slots = get_delivery_slots()
    if slots:
        msg = 'Delivery slots available'
    logout()
except Exception as e:
    msg = traceback.format_exc()

if msg:
    print(msg)
    headers = {
        'Access-Token': os.environ['PB_TOKEN'],
        'Content-Type': 'application/json'
    }
    data = {
        'title': 'iCart watcher',
        'body': msg,
        'type': 'note'
    }
    requests.post('https://api.pushbullet.com/v2/pushes', headers=headers, json=data)
else:
    print('No msg')
