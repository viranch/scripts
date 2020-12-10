import os, sys
import urllib.parse
import requests
import json
from lxml import html

makes = ['volkswagen', 'honda', 'kia', 'ford', 'toyota', 'subaru', 'mini', 'mazda', 'chevrolet', 'fiat', 'hyundai', 'nissan']
#search_terms = [search_terms[0]]

csv_header = []
net = requests.Session()

def net_get(url):
    fname = url.replace(':', '_').replace('/', '_')
    fpath = os.getenv('HOME') + f'/.cache/nhtsa/{fname}'
    try:
        s = open(fpath).read()
    except IOError:
        s = net.get(url, params={'format': 'json'}).text
        open(fpath, 'w').write(s)
    try:
        return json.loads(s)['Results']
    except json.decoder.JSONDecodeError:
        print(url)
        print(s)
        raise

all_cars = []
for make in makes:
    headers = {'content-type': 'application/json'}
    for year in range(2011, 2020):
        url = f'https://webapi.nhtsa.gov/api/SafetyRatings/modelYear/{year}/make/{make}'
        models = net_get(url)
        for model in models:
            #model = urllib.parse.quote(model['Model'], safe='')
            model = model['Model'].strip()
            if '/' in model:
                sys.stderr.write(f'Skipping {year} {make} {model}\n')
                continue
            vehicles = net_get(f'{url}/model/{model}')
            for vehicle in vehicles:
                vid = vehicle['VehicleId']
                sys.stderr.write(vehicle['VehicleDescription']+'\n')
                car = net_get(f'https://webapi.nhtsa.gov/api/SafetyRatings/VehicleId/{vid}')[0]
                for key in car:
                    if key not in csv_header:
                        csv_header.append(key)
                all_cars.append(car)

csv_header.remove('VehicleDescription')
csv_header.insert(0, 'VehicleDescription')
print(','.join('"'+header+'"' for header in csv_header))
for car in all_cars:
    print(','.join('"'+str(car.get(header, 'N/A'))+'"' for header in csv_header))
