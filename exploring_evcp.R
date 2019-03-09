
library(dplyr)

# You will need to edit the path of the document location
data <- read.csv("C:/Users/pierr/Documents/Projects/EV_Charge_Geo/data/data_evcp.txt", header= FALSE, sep = "\t")
colnames(data) <- c("Date", "Time", "ID", "Type", "Status", "Coordinates", "Address", "Latitude", "Longitude")
data <- data.frame(data)
head(data)

# Randomly selected location on a single day:
test <- data %>%
        filter(ID == 'CP:C5HD3'& Date == '20181102')
head(test)
test
