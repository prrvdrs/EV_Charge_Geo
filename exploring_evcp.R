
library(dplyr)

# EVCP Dataset Configuration:

# You will need to edit the path of the document location
data <- read.csv("C:/Users/pierr/Documents/Projects/EV_Charge_Geo/data/data_evcp.txt", header= FALSE, sep = "\t")
colnames(data) <- c("Date", "Time", "ID", "Type", "Status", "Coordinates", "Address", "Latitude", "Longitude")
data <- data.frame(data)

str(data)
data$Coordinates <- as.factor(paste(data$Longitude,',',data$Latitude))
summary(data)

###############################################################################
#                     Handeling Missing Values                                #
###############################################################################

df <- na.omit(data) # Remove rows with missing ID, Types and Status
df_1 <- df %>% group_by(Coordinates) %>% count(name = "n", sort=T)
plot(df_1$n, xlab = "Charging Station", ylab = "Status Count", main="Charging Station Coordinates")

# Represnt 
df_2 <- df %>% group_by(Coordinates, Type) %>% count(name = "n", sort=T)
plot(df_2$n, xlab = "Charging Station", ylab = "Status Count", main="Charging Station Coordinates by Type")


###############################################################################
#                     Handeling Duplicates and Caveats                        #
###############################################################################


# Handeling the following situation: https://www.esb.ie/our-businesses/ecars/how-to-charge-your-ecar
# Note- on a fast multi-standard charger you can only use one of the DC connectors (CHAdeMO and CCS)
# at a time, however it is possible for the DC connector and fast AC connector to be used at the same time

#df_dupl_stage1 <- dplyr::filter(df, grepl("CHAdeMO|ComboCCS",Type))
#df_dupl_stage1 %>% group_by(Type) %>% tally(sort = TRUE)
#df_dupl_stage2 <- df_dupl_stage1[duplicated(df_dupl_stage1), -c(4)] # check for duplicate row, ignoring the type column.
#df_dupl_stage3 <- df_dupl_stage2 %>% group_by(Coordinates) %>% tally(sort = TRUE)

df$NewType <- ifelse(grepl("StandardType2", df$Type), "StandardType2",
                     ifelse(grepl("CHAdeMO", df$Type), "CHAdeMO/ComboCCS", 
                            ifelse(grepl("ComboCCS", df$Type), "CHAdeMO/ComboCCS", "FastAC43")))

df %>% group_by(Type) %>% tally(sort = TRUE)
df %>% group_by(NewType) %>% tally(sort = TRUE)

df_test <- df[,-4]

df_test_dup <- df_test[duplicated(df_test), ] # removing duplicates

df_test_dup %>% group_by(NewType, ID) %>% tally(sort = TRUE)

# Example
df %>% filter(ID == "CP:RC17") %>% group_by(NewType, Type) %>% count()
df %>% filter(ID == "CP:RC17") %>% group_by(NewType) %>% count()
df_test_dup %>% filter(ID == "CP:RC17") %>% group_by(NewType) %>% count()

df_inter <- df_test[!duplicated(df_test), ]

#test4 <- df %>% group_by(Coordinates, NewType) %>% tally(sort = TRUE)
#test5 <- df_inter %>% group_by(Coordinates, NewType) %>% count(name = "n", sort=T)
#plot(test4$n, xlab = "Charging Station", ylab = "Status Count", main="Charging Station Coordinates by Type")
#plot(test5$n, xlab = "Charging Station", ylab = "Status Count", main="Charging Station Coordinates by Type")

df_cc <- df_inter %>% filter(grepl("CHAdeMO/ComboCCS",NewType))  %>% group_by(Coordinates, NewType) %>% tally(sort = TRUE)
plot(df_cc$n, xlab = "Charging Station", ylab = "Status Count", main="CC Station")

df_fast <- df_inter %>% filter(grepl("FastAC43",NewType))  %>% group_by(Coordinates, NewType) %>% tally(sort = TRUE)
plot(df_fast$n, xlab = "Charging Station", ylab = "Status Count", main="Fast Station")

df_st_occ <- df_inter %>% filter(grepl("StandardType2",NewType)) %>% filter(grepl("Occ",Status)) %>% group_by(Coordinates, NewType) %>% tally(sort = TRUE)
plot(df_st_occ$n, xlab = "Charging Station", ylab = "Status Count", main="Standard Station Fully Occupied")

df_st_part <- df_inter %>% filter(grepl("StandardType2",NewType)) %>% filter(grepl("Part",Status)) %>% group_by(Coordinates, NewType) %>% tally(sort = TRUE)
plot(df_st_part$n, xlab = "Charging Station", ylab = "Status Count", main="Standard Station Partially Occupied")


###############################################################################
#             Handeling Out of Service and Not Tracked                        #
###############################################################################


# Test staff
