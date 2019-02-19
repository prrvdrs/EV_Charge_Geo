
############################################################
##                                                        ##
## Attention: Generating Costs on Google Cloud Platforme  ##
##                                                        ##
############################################################

# API Test call

import json
import requests

def main():
    ''' Credential Acquisition. '''
    searchApi = get_api_key()
    evc_location = "53.392154,-6.392830"
    radius = "500"
    url = f"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={evc_location}&radius={radius}&key={searchApi}"
    response = requests.get(url)
    response.raise_for_status()  # ensure we notice bad responses
    file = open("resp_text.txt", "w")
    file.write(response.text)

def get_api_key():
    ''' Gets API key from a JSON file and returns it. '''
    with open("auth.json", "r") as a:
        data = json.load(a)
    return data["api_key"]

'''
def get_coordinates():
    ''' Get EVCP coordinates from txt file '''
    coordinates = open('coordinatesEVCP.txt', 'r')
    return coordinates
'''

if __name__ == main():
    main()
