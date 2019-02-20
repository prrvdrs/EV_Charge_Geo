import json
from pprint import pprint

from pandas.io.json import json_normalize

#loaded_json = json.loads("")

with open('raw_nearby_500_52.801581-6.736986.json', 'r') as f:
    data = json.load(f)
    pprint(data['results'])
    for i in data['results']:
        print(i)
        print(i['geometry'])