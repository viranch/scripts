import sys
import requests

username = sys.argv[1]
sk1, sk2 = sys.argv[2].split(',')
chat_id = sys.argv[3]

session = requests.Session()
session.headers.update({
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36'
})

def get_messages():
    while True:
        print('getting messages')
        d = session.get(f'https://sendbirdproxy.chat.redditmedia.com/v3/group_channels/{chat_id}/messages', params={
            'is_dsk': 'true',
            'prev_limit': 199,
            'next_limit': 0,
            'include': 'false',
            'reverse': 'false',
            'message_type': 'MESG',
            'message_ts': '9223372036854776000'
        }, headers={'Session-Key': sk1}).json()
        try:
            m = d['messages']
            print(f'got {len(m)} messages')
        except:
            print(d)
            raise
        if len(m) == 0:
            break
        for msg in m:
            if msg['user']['nickname'] == username:
                msg['sk'] = sk1
            else:
                msg['sk'] = sk2
            yield msg

for msg in get_messages():
    mid = msg['message_id']
    user = msg['user']['nickname']
    text = msg['message']
    print(f'deleting {user}: {text}')
    session.delete(f'https://sendbirdproxy.chat.redditmedia.com/v3/group_channels/{chat_id}/messages/{mid}', headers={'Session-Key': msg['sk']})
