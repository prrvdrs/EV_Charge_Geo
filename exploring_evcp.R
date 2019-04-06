
library(dplyr)

# EVCP Dataset Configuration:

# You will need to edit the path of the document location
data <- read.csv("C:/Users/pierr/Documents/Projects/EV_Charge_Geo/data/data_evcp.txt", header= FALSE, sep = "\t")
colnames(data) <- c("Date", "Time", "ID", "Type", "Status", "Coordinates", "Address", "Latitude", "Longitude")
data <- data.frame(data)

str(data)
data$Coordinates <- as.factor(paste(data$Longitude,',',data$Latitude))
summary(data)

# Handeling NA's:
df <- na.omit(data) # Remove rows with missing ID, Types and Status
df_1 <- df %>% group_by(Coordinates) %>% count(name = "n", sort=T)
plot(df_1$n, xlab = "Charging Station", ylab = "Status Count", main="Charging Station Coordinates")

# Represnt 
df_2 <- df %>% group_by(Coordinates, Type) %>% count(name = "n", sort=T)
plot(df_2$n, xlab = "Charging Station", ylab = "Status Count", main="Charging Station Coordinates by Type")

# Handeling the following situation: https://www.esb.ie/our-businesses/ecars/how-to-charge-your-ecar
# Note- on a fast multi-standard charger you can only use one of the DC connectors (CHAdeMO and CCS)
# at a time, however it is possible for the DC connector and fast AC connector to be used at the same time

# Example of fast multi-standard charger
test <- df %>% filter(Coordinates == "51.877 , -8.3954") %>% group_by(Type) %>% count()
test

# But in general there is an imbalance between CHAdeMO and CCS
table(df$Type) 

# Try to indentify all the Type FastAC43 connector with CHAdeMO and CCS:
df3 <- df %>% filter(Type == "FastAC43") %>% group_by(Coordinates, ID) %>% count(name = "n", sort=T)
df3
fast <- df3["ID"] # ID with FastAC43
fast

#df4 <- df %>% filter(ID = fast) %>% group_by(Coordinates, ID, Type) %>% count(name = "n", sort=T)


# Example of fast multi-standard charger
test <- df %>% filter(Coordinates == "51.877 , -8.3954") %>% group_by(Type) %>% count()
test

df %>% filter(Coordinates == "51.877 , -8.3954")

# Next step: Handling Caveats

# 1. Check for EVCP ID's with multiple locations.
# 2. Fast multi-standard charger display two records when CHAdeMO or CCS is in use.
#    Suggestion = unify both records when duplicated and diplay type as CHAdeMO/CCS
# 3. How to handle OOC records (out of contact).
