import sys, os
import emlx
import re
from datetime import datetime, timedelta, timezone

def display_time(sec):
    hours = int(sec/3600)
    mins = int(sec/60) % 60
    secs = sec % 60
    ago = ''
    if hours > 0:
        ago += f'{hours}h '
    if mins > 0:
        ago += f'{mins}m '
    if secs > 0:
        ago += f'{secs}s'
    return ago.strip()

def alert(sender, subject, folder, timeago):
    os.system(f"{alerter_cmd} -title '{sender}' -subtitle '{subject}' -message '{folder} ({timeago} ago)' &")

stdin = sys.stdin.read().strip()
if stdin:
    email_files = stdin.split('\n')
else:
    email_files = []

subject_regex = re.compile(r'^[Rr][Ee]: ')
mbox_regex = re.compile(r'[^/]+\.mbox')
now = datetime.now(timezone.utc)
alerter_cmd = os.getenv('HOME') + '/bin/alerter -appIcon /System/Applications/Mail.app/Contents/Resources/ApplicationIcon.icns -timeout 10'

latest_threads = {}

for f in email_files:
    m = emlx.read(f).headers
    date = datetime.strptime(m['Date'], '%a, %d %b %Y %H:%M:%S %z')
    if date < now - timedelta(hours=1):
        continue
    m['Date'] = date
    m['__file__'] = f
    subject = subject_regex.sub('', m['Subject']).replace('\n', '')
    m['Subject'] = subject
    if latest_threads.setdefault(subject, m)['Date'] < date:
        latest_threads[subject] = m

emails = list(latest_threads.values())
emails.sort(key=lambda m: m['Date'])
top_threads = emails[-5:]

for email in top_threads:
    sender = email['From'].split('<')[0].strip()
    subject = email['Subject']
    folder = '/'.join(f.replace('.mbox', '') for f in mbox_regex.findall(email['__file__']))
    date = email['Date']
    timeago = display_time((now - date).seconds)
    alert(sender, subject, folder, timeago)
