
library(dplyr)
library(tidyr)
library(data.table)

data <- read.csv("C:/Users/pierr/Documents/Projects/EV_Charge_Geo/data/201903a.txt", header= FALSE, sep = "\t")
colnames(data) <- c("Date", "Time", "ID", "Type", "Status", "Coordinates", "Address", "Latitude", "Longitude")
df <- data.frame(data)
setDT(df)


###############################################################################
#                     Handeling Missing Values                                #
###############################################################################

#df <- na.omit(df) # Remove rows with missing ID, Types and Status


###############################################################################
#                     Handeling Duplicates and Caveats                        #
###############################################################################

df <- df %>% filter(!grepl("OOC|OOS",Status)) # Does not contain Out of Contact or Out of Service

df$NewType <- ifelse(grepl("StandardType2", df$Type), "StandardType2",
                     ifelse(grepl("CHAdeMO", df$Type), "CHAdeMO/ComboCCS", 
                            ifelse(grepl("ComboCCS", df$Type), "CHAdeMO/ComboCCS", "FastAC43")))

df$Coordinates <- as.factor(paste(df$Longitude,',',df$Latitude))

df <- df[,-9]
df <- df[,-8]
df <- df[,-4] #Remove Type Column
class(df)
setDT(df)

df$Hour <- cut(df$Time,
               breaks = c(0,100,200,300,400,500,600,700,800,900,1000,1100,1200,1300,1400,1500,1600,1700,1800,1900,2000,2100,2200,2300,2400),
               labels=c("0","1", "2", "3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23"))
df <- na.exclude(df)

library(lubridate)
df$Datetime <- ymd_h(paste0(df$Date," ",df$Hour))

str(df)
df <- df[,-2]
df <- df[!duplicated(df), ] # Remove Duplicates

testing <- df %>% group_by(Hour) %>% tally()
plot(testing$n)

############### Handeling Standard Occ and Part Overlap

df_st <- df %>% filter(NewType == "StandardType2")
df_other <- df %>% filter(NewType != "StandardType2")

df_st <- df_st[order(df_st$Status),]
df_st <- df_st[!duplicated(df_st[,-3], fromLast = FALSE),]
# df_st_dub <- df_st[duplicated(df_st[,-3], fromLast = FALSE),] # For control

df <- rbind(df_st,df_other)
hourly <- df %>% group_by(Hour, .drop = FALSE) %>% tally()
barplot(hourly$n)


########## Complete data for non-busy hours
library(dplyr)
library(tidyr)
library(lubridate)
library(zoo)

x <- "201903"
y <- "2019-03-01 00:00:00"
z <- "2019-03-31 23:00:00"

test <- df %>% filter(grepl(x,Date))
test$Datetime <- as.POSIXct(test$Datetime)
test <- test %>% group_by(Coordinates, ID, NewType) %>% complete(Datetime = seq(as.POSIXct(y), as.POSIXct(z), by="hour"))
test$Date <- as.Date(test$Datetime, format = '%Y%m%d')
test$Hour <- strftime(test$Datetime, format="%H")
test$Status = factor(test$Status, levels=c(levels(test$Status), "Empty"))
test$Status[is.na(test$Status)] = "Empty"
test <- test %>% group_by(Coordinates, ID, NewType) %>% mutate(Address = na.locf(Address, fromLast = FALSE, na.rm = F)) %>% mutate(Address = na.locf(Address, fromLast = TRUE, na.rm = F))

sapply(test,function(x) sum(is.na(x))) # Make sure that all the NA have been accounted for and handeld.



# Create New Features:
test$Weekday <- weekdays(test$Datetime)
test$Weekday <- factor(test$Weekday, levels= c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))
test$Month <- months(test$Datetime)
test$Year <- format(as.Date(test$Datetime, format="%d/%m/%Y"),"%Y")
library(stringr)
test$Country <- ifelse(grepl("County (\\w+)", test$Address), "Republic of Ireland", "Northern Ireland")
test$County <- ifelse(grepl("County (\\w+)", test$Address), str_extract(test$Address, "County (\\w+)"), "Not Defined")
table(test$County)

# Save to CSV
write.csv(test, file = "new_clean_evcp_201903.csv")


######### Percentage Graph ########

test <- read.csv("C:/Users/pierr/Documents/Projects/EV_Charge_Geo/data/new_clean_evcp_201903.csv", header= TRUE)

str(test)

test <- test[,-1]

test$Hour <- factor(test$Hour)

empty <- test %>% filter(Status == "Empty") %>% group_by(Hour,.drop = FALSE) %>% tally()
all <- test %>% group_by(Hour,.drop = FALSE) %>% tally()
barplot(all$n)
occ <- test %>% filter(Status != "Empty") %>% group_by(Hour,.drop = FALSE) %>% tally()
pc <- occ$n / all$n
barplot(pc)
barplot(occ$n)


test1 <- test %>% filter(NewType == "CHAdeMO/ComboCCS") %>% filter(Coordinates =="53.392154 , -6.39283")
test2 <- test1 %>% group_by(Hour,.drop = FALSE) %>% tally()

pln <- test1 %>% filter(Status == "Empty") %>% group_by(Hour,.drop = FALSE) %>% tally()

pln$n

pl <- test1 %>% filter(Status != "Empty") %>% group_by(Hour,.drop = FALSE) %>% tally()

pl$n

barplot(pl$n)

empty <- test1 %>% filter(Status == "Empty") %>% group_by(Hour) %>% tally()
occ <- test1 %>% filter(Status != "Empty") %>% group_by(Hour) %>% tally()
pc1 <- occ$n / 31 #number of days.
barplot(pc1)

test1 %>% group_by(Hour) %>% tally()



# model
reg <- subset(test, Status != "Part")
table(reg$Status)
reg$Status <- factor(reg$Status)
table(reg$Status)
reg$Status <- factor(reg$Status, levels=rev(levels(reg$Status)))
reg$Status <- factor(reg$Status, levels = c("Empty","Occ"), labels = c("0",	"1"))
table(reg$Status)
training <- reg[1:300000,]
testing <- reg[300001:350000,]
#reg <- subset(training, Status != "Part")
#table(reg$Status)
#reg$Status <- factor(reg$Status)
#table(reg$Status)
#reg$Status <- factor(reg$Status, levels=rev(levels(reg$Status)))
#table(reg$Status)

mylogit <- glm(Status ~ Hour + Weekday + NewType + County, data = training, family = "binomial")
summary(mylogit)

anova(mylogit, test="Chisq")

fitted.results <- predict(mylogit,newdata=testing,type='response')
fitted.results <- ifelse(fitted.results > 0.6,1,0)
misClasificError <- mean(fitted.results != testing$Status)
print(paste('Accuracy',1-misClasificError))

fitted.results <- factor(fitted.results)
str(fitted.results)
str(testing$Status)

library(caret)
cf <- confusionMatrix(fitted.results, testing$Status, positive = "1")
cf


###################
library(C50)
cFifty <- C5.0(Status ~ Hour + Weekday + NewType + County, data=training, trials=10)
plot(cFifty)
summary(cFifty) 

library(caret)
c <- predict(cFifty, testing[, -6])
caret::confusionMatrix(c, testing$Status, positive="1")

cFiftyWinnow <- C5.0(Status ~ Hour + Weekday + NewType + County, data=training, control = C5.0Control(winnow = TRUE))
cw <-  predict(cFiftyWinnow, testing[, -6])
caret::confusionMatrix(cw, testing$Status, positive="1")


# df_key <- df %>% group_by(Coordinates, ID) %>% summarize(count=n())
# df_key <- df_key[,c(1:2)]
# 
# df_key_check <- df_key %>% group_by(ID) %>% summarize(count=n())
# 
# df_key_check  %>% filter(df_key_check$count > 1)

###### Duplicat CHAdeMO and ComboCCS

###### Paritally and Fully Occupied StandardType2

###### Additional Features

# library(stringr)
# df$County <- str_extract(df$Address, "County (\\w+)") # Ireland
# #str_extract(df$Address,"") #Northern Ireland
# 
# df$Address
# str_extract(df$Address, "County (\\w+)")
# 
# 
# plot(df$Hour)
# plot(df$Weekday)
# 
# head(df$Date)
# 
# # Do hour weekday heatmap
# 
# library(highcharter)
# heatmap_data <- df %>% group_by(Hour,Weekday) %>% tally()
# heatmap_data <- select(heatmap_data, Weekday, Hour, n)
# heatmap_sums <- group_by(heatmap_data, Weekday, Hour) %>%
#   summarise(n = sum(n))
# # Now, "spread" the data out so it's heatmap-ready
# heatmap_recast <- spread(heatmap_sums, Hour, n)
# # Make this "data frame" into a "matrix"
# heatmap_matrix <- as.matrix(heatmap_recast[-1])
# # Name the rows to match the weeks
# row.names(heatmap_matrix) <- c("Monday","Tuesday","Wednesday",
#                                "Thursday","Friday","Saturday","Sunday")
# hchart(heatmap_matrix, type = "heatmap")
# 
# 
# ######## Handeling Standard Partial and Full:
# 
# 
# #df_st_occ <- df %>% filter(grepl("StandardType2",NewType)) %>% filter(grepl("Occ",Status))
# 
# #df <- rbind(df, df_st_occ)
# 
# # df_test_plot <- df %>% group_by(Coordinates) %>% tally(sort = T)
# # plot(df_test_plot$n, xlab = "Charging Station", ylab = "Status Count")
# # head(df_test_plot) # Airport has the highest count.
# 
# df <- na.exclude(df)
# 
# str(df)
# # Drop Time
# df_test <- df
# 
# df_test <- df_test[,-3]
# df_test <- df_test[,-2]
# 
# df_test$Datetime <- ymd_h(paste0(df_test$Date," ",df$Hour))
# 
# df_test <- unique(df_test) #
# 
# #df_test1 <- group_by_all(df_test) %>% tally(name = "Observations")
# 
# 
# # memory.limit()
# # memory.limit(size=56000)
# # 
# # df %>% filter(Coordinates == "53.362913 , -6.227746") %>% filter(Date =="2018-01-01") %>% filter(Hour == 15)
# # 
# # write.csv(df, file = "evcp.csv")
# 
