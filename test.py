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