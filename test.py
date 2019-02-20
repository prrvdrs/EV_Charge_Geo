import geopy.distance

coords_1 = (52.802547,-6.7371517)
coords_2 = (52.801581,-6.736986)

print (geopy.distance.vincenty(coords_1, coords_2).km)

'''
import csv

def main():
    with open('data/coordinates_EVCP.csv') as coordinates:
        reader = csv.reader(coordinates)
        for i in reader:
            c = ''.join(i)
            url = f"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={c}"
            print(url)

if __name__ == main():
    main()
'''