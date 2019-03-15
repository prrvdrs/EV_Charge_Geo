
library(dplyr)
library(klaR)

# You will need to edit the path of the document location
data <- read.csv("C:/Users/pierr/Documents/Projects/EV_Charge_Geo/data/data_test_poi.csv", header= TRUE, sep = ",")
data <- data.frame(data)
data$type_raw <- toString(data$type_raw)

head(data)

# Drop the last column 'type'
#test <- select (data,-c(type_one))

# Only take into account points of interests (not loicality or political)
test <- dplyr::filter(data, grepl('point_of_interest',type_raw))

# Clustering Categorical Data
# https://dabblingwithdata.wordpress.com/2016/10/10/clustering-categorical-data-with-r/

# Cluster
cluster_results <-kmodes(test[,14:141], 13, iter.max = 10, weighted = FALSE )
cluster_results

test2 <- #te<- select (data,-c(type_one))
test2 <-  data %>%
          filter(#test <- select (data,-c(type_one)))

