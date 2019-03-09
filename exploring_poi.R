
library(dplyr)

data <- read.csv("C:/Users/pierr/Documents/Projects/EV_Charge_Geo/data/data_poi.csv", header= TRUE, sep = ",")
data <- data.frame(data)
head(data)

# Drop the last column 'typ'
test <- select (data,-c(type))
head(test)

# Only take into account points of interests (not loicality or political)
test <- test %>%
        filter(type_raw == 'point_of_interest')