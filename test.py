import geopy.distance
import csv
from pprint import pprint
import matplotlib.pyplot as plt
'''
from sklearn.cluster import KMeans


import pandas as pd

df = pd.read_csv("data/locationOfInterests.csv")

#ka = np.array(df['labeling'])

test =df.iloc['labeling'].values
#kl = list(df['labeling'].str.replace("'", ""))
print(test)
kmeans = KMeans(n_clusters=2)


coords_1 = (52.802547,-6.7371517)
coords_2 = (52.801581,-6.736986)

#print (geopy.distance.vincenty(coords_1, coords_2).km)



import numpy as np
from scipy.spatial import distance

x = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
y = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

print(distance.jaccard(x, y))

'''
import csv
import os
import re

directory = 'C:/Users/pierr/Documents/Projects/EV_Charge_Geo/data/API_Response'

for filename in os.listdir(directory):
    if filename.endswith(".json"):
        #f = open(filename)
        print(os.path.join(directory, filename))
        print(filename)
        m = re.search('(\d{1,2}\.\d+\-\d{1,2}\.\d+)', filename)
        n = re.sub('-',',-',m.group(0))
        print(n)
    else:
        continue