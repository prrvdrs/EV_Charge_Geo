import pandas as pd

df = pd.read_csv("data/201811a.txt", delimiter= "\t", lineterminator="\n", encoding="latin-1",
                 names = ["Date", "Time", "ID", "Type", "Status", "KML_Coordinates", "Address", "Longitude", "Latitude"])

'''
Extracting all unique coordinates
'''

df["Coordinates"] = df['Latitude'].astype(str) +','+ df['Longitude'].astype(str)
df2 = df[~df["Coordinates"].str.contains('0.0,0.0')]
df3 = df2["Coordinates"].unique()
df4 = pd.Series(df3)
df4.to_csv('data/coordinates_EVCP.csv', encoding='utf-8', index=False)