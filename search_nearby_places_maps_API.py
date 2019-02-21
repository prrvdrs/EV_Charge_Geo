
############################################################
##                                                        ##
## Attention: Generating Costs on Google Cloud Platforme  ##
##                                                        ##
############################################################

import json
import requests
import time
import csv

def main():
    searchApi = get_api_key()
    radius = "500"
    with open('data/coordinates_EVCP.csv') as coordinates:
        reader = csv.reader(coordinates)
        for i in reader:
            c = ''.join(i)
            s = c.replace(',','')
            url = f"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={c}&radius={radius}&key={searchApi}"
            print(url)
            try:
                response = requests.get(url)
                response.raise_for_status()  # ensure we notice bad responses
                file = open(f"data/API_Response/raw_nearby_500_{s}.json", "w")
                file.write(response.text)
            except:
                continue
            time.sleep(1)  # limit requests per second.

def get_api_key():
    ''' Gets API key from a JSON file and returns it. '''
    with open("auth.json", "r") as a:
        data = json.load(a)
    return data["api_key"]

if __name__ == main():
    main()