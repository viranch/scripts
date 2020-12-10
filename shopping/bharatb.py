import traceback
import requests
import json

session = requests.Session()
session.headers.update({'Content-Type': 'application/json', 'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36', 'apikey': 'E1A8FB6C-6EAE-447C-947A-88D4AD890F4C'})

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
    s = _call('https://partnersapi.gethomesome.com/user/login', json_data={"user":{"emailId":username,"password":password}})
    try:
        session.headers.update({
            'authToken': s['authToken'],
            'emailid': s['email']
        })
    except KeyError:
        raise Exception(s)

def get_slots():
    s = _call('https://partnersapi.gethomesome.com/user/basket')
    o = s['orderFee']
    return (
        o[method].get('unavailable', {}).get('reason') != 'At Capacity' and len(o[method]['availableTimes']) > 0
        for method in ['pickup', 'delivery']
    )

msg = None
try:
    login(os.environ['username'], os.environ['password'])
    pickup, delivery = get_slots()
    if pickup and delivery:
        msg = 'Pickup/delivery available'
    elif pickup:
        msg = 'Pickup available'
    elif delivery:
        msg = 'Delivery available'
except:
    msg = traceback.format_exc()

if msg:
    print(msg)
    headers = {
        'Access-Token': os.environ['PB_TOKEN'],
        'Content-Type': 'application/json'
    }
    data = {
        'title': 'Bb watcher',
        'body': msg,
        'type': 'note'
    }
    requests.post('https://api.pushbullet.com/v2/pushes', headers=headers, json=data)
else:
    print('No msg')
