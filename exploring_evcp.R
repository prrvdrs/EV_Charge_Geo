
library(dplyr)

# EVCP Dataset Configuration:

# You will need to edit the path of the document location
data <- read.csv("C:/Users/pierr/Documents/Projects/EV_Charge_Geo/data/data_evcp.txt", header= FALSE, sep = "\t")
colnames(data) <- c("Date", "Time", "ID", "Type", "Status", "Coordinates", "Address", "Latitude", "Longitude")
data <- data.frame(data)

# Coordinates have the wrong format, rearranging the coorinates column
data$Coordinates <- as.factor(paste(data$Longitude,',',data$Latitude))
head(data)
# Test: Randomly selected location on a single day for a fast multi-standard charger
test <- data %>%
        filter(ID == 'CP:C5HD3'& Date == '20181102')
head(test)
test

# Next step: Handling Caveats

# 1. Check for EVCP ID's with multiple locations.
# 2. Fast multi-standard charger display two records when CHAdeMO or CCS is in use.
#    Suggestion = unify both records when duplicated and diplay type as CHAdeMO/CCS
# 3. How to handle OOC records (out of contact).
