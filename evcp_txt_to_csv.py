import csv

# Convert .txt file to .csv:

csvfile = open('data/evcp_201811.csv', 'w')
writer = csv.writer(csvfile, delimiter=',', lineterminator='\n', quotechar='"')
writer.writerow(
    ["Date", "Time", "ID", "Type", "Status", "Coordinates", "Address", "Latitude", "Longitude"])

with open('data/201811a.txt', 'r') as f:
    reader = csv.reader(f, dialect='excel', delimiter='\t')
    for row in reader:
        print (row)
        writer.writerow(row)
