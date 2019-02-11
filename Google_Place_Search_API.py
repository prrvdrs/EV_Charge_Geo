import json


auth = api_key
evc_location = [] #example_= -33.8670522,151.1957362
radius = 500 #

request = f"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={evc_location}&radius={radius}&key={auth}"