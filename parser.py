import json
import geopy.distance
import pandas as pd
import csv
from pprint import pprint

csvfile = open('data/locationOfInterests.csv', 'w')
writer = csv.writer(csvfile, delimiter=',',lineterminator='\n',quotechar = '"')
writer.writerow(["CoordinatesCP","CoordinatesPI","DistanceVincenty","ID","Name", "PlaceId","Scope", "Vicinity", "Types"])

with open('raw_nearby_500_52.801581-6.736986.json', 'r') as f:
    data = json.load(f)
    #pprint(data['results'])
    for i in data['results']:
        #print(i)
        #print('geometry')
        coordinatesCP = "52.801581,-6.736986" #Needs to be a dynamic process!
        coordinatesPI = str(i['geometry']['location']['lat']) + ',' + str(i['geometry']['location']['lng'])
        distanceVincenty = geopy.distance.vincenty(coordinatesCP, coordinatesPI).km
        id = i['id']
        name = i['name']
        placeId = i['place_id']
        scope = i['scope']
        vicinity = i['vicinity']
        types = i['types']
        #print(i['id'], i['name'], i['scope'], i['types'])
        writer.writerow([coordinatesCP, coordinatesPI, distanceVincenty, id, name, placeId, scope, vicinity, types])