import json
import geopy.distance
import pandas as pd
import csv
from pprint import pprint

csvfile = open('data/locationOfInterests.csv', 'w')
writer = csv.writer(csvfile, delimiter=',',lineterminator='\n',quotechar = '"')
writer.writerow(["coordinates_cp","coordinates_pi","distance_vincenty","id","name", "place_id", "rating", "user_rating","scope", "vicinity",
                 "type_raw", "type_one", "type_two", "type_three"])

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

        ''' Extract Rating '''
        if 'rating' not in i:
            rating = ''
        else:
            rating = i['rating']

        ''' # of User Ratings '''
        if 'user_ratings_total' not in i:
            userRating = ''
        else:
            userRating = i['user_ratings_total']

        scope = i['scope']
        vicinity = i['vicinity']
        typeRaw = i['types']

        ''' Google Classification 1 '''
        googlePlacesTypeOne = ["administrative_area_level_1","administrative_area_level_2",
                               "administrative_area_level_3","administrative_area_level_4",
                               "administrative_area_level_5","colloquial_area","country",
                               "establishment","finance","floor","food","general_contractor","geocode","health",
                               "intersection","locality","natural_feature","neighborhood","place_of_worship",
                               "political","point_of_interest","post_box","postal_code","postal_code_prefix",
                               "postal_code_suffix","postal_town","premise","room","route","street_address",
                               "street_number","sublocality","sublocality_level_4","sublocality_level_5",
                               "sublocality_level_3","sublocality_level_2","sublocality_level_1","subpremise"]

        ''' Google Classification 2'''

        googlePlacesTypeTwo = ["accounting","airport","amusement_park","aquarium","art_gallery","atm","bakery","bank",
                               "bar","beauty_salon","bicycle_store","book_store","bowling_alley","bus_station","cafe",
                               "campground","car_dealer","car_rental","car_repair","car_wash","casino","cemetery",
                               "church","city_hall","clothing_store","convenience_store","courthouse","dentist",
                               "department_store","doctor","electrician","electronics_store","embassy","fire_station",
                               "florist","funeral_home","furniture_store","gas_station","gym","hair_care",
                               "hardware_store","hindu_temple","home_goods_store","hospital","insurance_agency",
                               "jewelry_store","laundry","lawyer","library","liquor_store","local_government_office",
                               "locksmith","lodging","meal_delivery","meal_takeaway","mosque","movie_rental",
                               "movie_theater","moving_company","museum","night_club","painter","park","parking",
                               "pet_store","pharmacy","physiotherapist","plumber","police","post_office",
                               "real_estate_agency","restaurant","roofing_contractor","rv_park","school","shoe_store",
                               "shopping_mall","spa","stadium","storage","store","subway_station","supermarket",
                               "synagogue","taxi_stand","train_station","transit_station","travel_agency",
                               "veterinary_care","zoo"]
        #googlePlacesTypeThree = []
        typeOne = []
        for p in set(typeRaw).intersection(set(googlePlacesTypeOne)):
            typeOne.append(p)
        typeTwo = []
        for q in set(typeRaw).intersection(set(googlePlacesTypeTwo)):
            typeTwo.append(q)
        typeThree = "placeholder"
        #print(i['id'], i['name'], i['scope'], i['types'])
        writer.writerow([coordinatesCP, coordinatesPI, distanceVincenty, id, name, placeId, rating, userRating, scope, vicinity, typeRaw,
                         typeOne, typeTwo, typeThree])