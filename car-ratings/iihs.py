import os, sys
import requests
import json
from lxml import html
from ratelimit import limits, sleep_and_retry

search_terms = ['vw', 'honda', 'kia', 'ford', 'toyota', 'subaru', 'mini', 'mazda', 'chevrolet', 'fiat', 'hyundai', 'nissan']
#search_terms = [search_terms[0]]

csv_header = ['Car', 'Year', 'Type']
airtable = requests.Session()
api_key = os.environ['api_key']

@sleep_and_retry
@limits(calls=5, period=1)
def create_car(car):
    r = airtable.post(
        'https://api.airtable.com/v0/appse5VsenPUGnp2j/IIHS',
        headers={'Authorization': f'Bearer {api_key}', 'Content-Type': 'application/json'},
        json={'fields': car, 'typecast': True}
    )
    print(r)

all_cars = []
for st in search_terms:
    headers = {'content-type': 'application/json'}
    for year in range(2011, 2020):
        data = {'search': f'{year} {st}'}
        try:
            cars = open(os.getenv('HOME') + f'/.cache/iihs/search_{year}_{st}').read()
        except IOError:
            cars = requests.post('https://www.iihs.org/api/ratings/search-rated-vehicle-lookup', headers=headers, json=data).text
            open(os.getenv('HOME') + f'/.cache/iihs/search_{year}_{st}', 'w').write(cars)
        finally:
            cars = json.loads(cars)
        for car in cars:
            #print(car['ModelYear'], car['Title'])
            #print(car['Title']); sys.stdout.flush()
            sys.stderr.write(car['Title'] + "\n")
            my_car = {
                'Car': car['Title'],
                'Year': car['ModelYear'],
                'Type': car['VariantType']
            }
            my_car['Car'] = my_car['Car'].replace(f'{my_car["Year"]} ', '').replace(f' {my_car["Type"]}', '')
            path = car['UrlSuffix']
            try:
                car_page = open(os.getenv('HOME') + '/.cache/iihs/carpage_' + path.replace('/', '_',).replace(' ', '-')).read()
            except IOError:
                car_page = requests.get(f'https://www.iihs.org/ratings/vehicle/{path}').text
                open(os.getenv('HOME') + '/.cache/iihs/carpage_' + path.replace('/', '_',).replace(' ', '-'), 'w').write(car_page)
            tree = html.fromstring(car_page)
            try:
                my_car['Photo'] = [{'url': 'https://www.iihs.org' + tree.xpath('//div[@class="vehicle-right"]/figure/img/@src')[0]}]
            except IndexError:
                my_car['Photo'] = [{'url': ''}]
            crashworthiness = tree.xpath('//h4[text()="Crashworthiness"]/following-sibling::table[1]/tbody/tr')
            for entry in crashworthiness:
                thing = entry.xpath('./th/a/text()')[0]
                try:
                    rating = entry.xpath('./td/div/span/@aria-label')[0]
                except IndexError:
                    rating = entry.xpath('./td/div/div/span/@aria-label')[0]
                my_car[thing] = rating
                if thing not in csv_header:
                    csv_header.append(thing)
            crash_avoidance = tree.xpath('//h4[text()="Crash avoidance & mitigation"]/following-sibling::table[1]/tbody/tr')
            try:
                headlights_rating = crash_avoidance[0].xpath('./td/div/span/@aria-label')[0]
            except IndexError:
                next_idx = 0
            else:
                headlights = crash_avoidance[0].xpath('./th/a/text()')[0]
                my_car[headlights] = headlights_rating
                if headlights not in csv_header:
                    csv_header.append(headlights)
                next_idx = 1
            try:
                front_system = crash_avoidance[next_idx].xpath('./th/a/text()')[0]
            except IndexError:
                pass
            else:
                for entry in crash_avoidance[next_idx+1:]:
                    thing = front_system + ' (' + entry.xpath('./td[1]/text()')[0] + ')'
                    rating = entry.xpath('./td[2]/div/div/text()')[0]
                    my_car[thing] = rating
                    if thing not in csv_header:
                        csv_header.append(thing)
            all_cars.append(my_car)
            if my_car['Type'] in ['4-door SUV', '4-door hatchback', '4-door sedan']:
                create_car(my_car)

sys.exit(0)
csv_header.append('Photo')
print(','.join('"'+header+'"' for header in csv_header))
for car in all_cars:
    print(','.join('"'+str(car.get(header, 'N/A'))+'"' for header in csv_header))
