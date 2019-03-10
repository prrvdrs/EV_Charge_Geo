
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
    with open('data/stage_evcp.csv') as coordinates:
        reader = csv.reader(coordinates)
        for i in reader:
            c = ''.join(i)
            s = c.replace(',','')
            try:
                url = f"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={c}&radius={radius}&key={searchApi}"
                print(url)
                response = requests.get(url)
                res = response.json()
                file = open(f"data/API_Response/raw_nearby_500_{s}_1.json", "w", encoding="utf-8")
                file.write(response.text)
                if "next_page_token" not in res:
                    pagetoken = ''
                else:
                    pagetoken = res["next_page_token"]
                if pagetoken is not None:
                    time.sleep(5)
                    url2 = f"https://maps.googleapis.com/maps/api/place/nearbysearch/json?&pagetoken={pagetoken}&key={searchApi}"
                    print(url2)
                    response2 = requests.get(url2)
                    res2 = response2.json()
                    file2 = open(f"data/API_Response/raw_nearby_500_{s}_2.json", "w", encoding="utf-8")
                    file2.write(response2.text)
                    if "next_page_token" not in res2:
                        pagetoken2 = ''
                    else:
                        pagetoken2 = res2["next_page_token"]
                    if pagetoken2 is not None:
                        time.sleep(5)
                        url3 = f"https://maps.googleapis.com/maps/api/place/nearbysearch/json?&pagetoken={pagetoken2}&key={searchApi}"
                        print(url3)
                        response3 = requests.get(url3)
                        #res3 = response3.json()
                        file3 = open(f"data/API_Response/raw_nearby_500_{s}_3.json", "w", encoding="utf-8")
                        file3.write(response3.text)
                    else:
                        print("No third page")
                else:
                    print("No second page")
            except:
                continue
            time.sleep(2)  # limit requests per second.

def get_api_key():
    ''' Gets API key from a JSON file and returns it. '''
    with open("auth.json", "r") as a:
        data = json.load(a)
    return data["api_key"]

if __name__ == main():
    main()