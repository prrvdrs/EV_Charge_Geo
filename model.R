
# Open data: January 2018 to March 2019

data <- read.csv("C:/Users/pierr/Documents/Projects/EV_Charge_Geo/data/evcp_main_all.csv", header= TRUE) # may take a couple of seconds to laod.

# Setup

library(dplyr)
library(tidyr)
library(data.table)


setDT(data) # Transforms data.frame to data.table which is more effiecent when hadeling 6 Million rows.

data <- data[,-c(1,3)] # drop index columns 1 and 3

data$Hour <- factor(data$Hour)
data$Year <- factor(data$Year)

str(data)
# Missing Values

sapply(data,function(x) sum(is.na(x))) # There are 16 NA rows
data <- na.omit(data) # We omit them.


# Data Exploration:

# Hour of the Day


occupied <- data %>% filter(Status != "Empty") %>% group_by(Hour,.drop = FALSE) %>% tally()
plot(occupied$n,main = "All occupied occurencies by hour of the day", xlab =" Hour of the Day", ylab = "Occurence")

empty <- data %>% filter(Status == "Empty") %>% group_by(Hour,.drop = FALSE) %>% tally()
plot(empty$n,main = "All empty occurencies by hour of the day", xlab =" Hour of the Day", ylab = "Occurence")

all_hours <- data %>% group_by(Hour,.drop = FALSE) %>% tally() #Used to calculate %

occupation_rate <- occupied$n / all_hours$n
plot(occupation_rate, main = "Overall Occupation rate", xlab =" Hour of the Day", ylab = "Occupation rate")

# Popular stations?
stations <- data %>% filter(Status != "Empty") %>% group_by(Coordinates,NewType) %>% tally(sort=TRUE)
plot(stations$n) # A small number of stations are responsible for an importnat amount of occupied stations.


# Keep exploring!!!!!!!!!!!



##################################################

# Hypothesis only Modleing Cuunty Dublin March 2019 (due to computational limiation)

# Using a subset of the data

model_data <- data %>% filter(Year == '2019') %>% filter(Month == 'March') %>% filter(County =="County Dublin")

write.csv(model_data, file = "evcp_main_subset_dublin.csv")

table(model_data$Status) # Three types: Empty, Occ and Part. Handeling Part as Occ

model_data$Status <- ifelse(grepl("Occ", model_data$Status), "Occ",
                            ifelse(grepl("Part", model_data$Status), "Occ",
                                   "Empty"))


occupied <- model_data %>% filter(Status != "Empty") %>% group_by(Hour,.drop = FALSE) %>% tally()
plot(occupied$n,main = "County Dublin March 2019", xlab =" Hour of the Day", ylab = "Occurence")

empty <- model_data%>% filter(Status == "Empty") %>% group_by(Hour,.drop = FALSE) %>% tally()
plot(empty$n,main = "All empty occurencies by hour of the day", xlab =" Hour of the Day", ylab = "Occurence")

all_hours <- model_data %>% group_by(Hour,.drop = FALSE) %>% tally() #Used to calculate %


occupation_rate <- occupied$n / all_hours$n
barplot(occupation_rate,
        main = "County Dublin Occupation Rate - March 2019",
        xlab =" Hour of the Day",
        ylab = "Occupation rate",
        names.arg=c("0", "1" , "2","3", "4", "5", "6" , "7","8", "9", "10", "11", 
                    "12", "13" , "14","15", "16", "17", "18" , "19","20", "21", "22", "23" ))


model_data$Status <- factor(model_data$Status, levels = c("Empty","Occ"), labels = c("0",	"1"))
table(model_data$Status)

model_data <- data.frame(model_data)

model_data <- model_data[, -13] # Remove Year
model_data <- model_data[, -12] # Remove Year
model_data <- model_data[, -11] # Remove Year
model_data <- model_data[, -10] # Remove Address
model_data <- model_data[, -7] # Remove Address
model_data <- model_data[, -5] # Remove Date
model_data <- model_data[, -4] # Remove Datime
model_data <- model_data[, -2] # Remove ID
model_data <- model_data[, -1] # Remove Cordinates

# Normalization

num <- sapply(model_data, function(x) {is.numeric(x)}) # Get Numerics
model_numeric <- model_data[, num]
summary(model_numeric)

normalize <- function(x) { return ((x - min(x)) / (max(x) - min(x))) }
model_numeric_normal <- normalize(model_numeric)
summary(model_numeric_normal)

model_categorical <- model_data[, !num]

model_data_norm <- cbind(model_categorical,model_numeric_normal)

setDT(model_data_norm)

sapply(model_data_norm,function(x) sum(is.na(x))) # There are 16 NA rows

str(model_data_norm)


# Training and Testing Data

set.seed(18142923)

# Non-Normalized
index <- sample(1:dim(model_data)[1], dim(model_data)[1] * .75, replace=FALSE)
training <- model_data[index, ]
testing <- model_data[-index, ]

# Normalized
indexN <- sample(1:dim(model_data_norm)[1], dim(model_data_norm )[1] * .75, replace=FALSE)
trainingN <- model_data_norm[indexN, ]
testingN <- model_data_norm[-indexN, ]

# memory.limit()
memory.limit(size=56000)

# # # # # # # # # # # # # # 
# Random Forest Benchmark #
# # # # # # # # # # # # # # 

library(randomForest)
rf <- randomForest(Status ~ ., data=training, importance=TRUE, ntree=100) # Takes a long time to compute
varImpPlotData <- varImpPlot(rf)

library(caret)

rf_predict <- predict(rf, testing[, -2])
rf_predict1 <- predict(rf, testing[, -2], type="prob")

caret::confusionMatrix(rf_predict, testing$Status, positive="1")


# Accuracy : 0.8177
# Kappa : 0.4814 

roc(testingN$Status, rf_predict1[,2], plot=TRUE)

# # # # # # # # # # # # # # 
#       Logit Model       #
# # # # # # # # # # # # # # 


mylogit <- glm(Status ~ ., data = trainingN, family = "binomial")
summary(mylogit)

anova(mylogit, test="Chisq")

fitted.results <- predict(mylogit,newdata=testingN,type='response')
fitted.results_conf <- ifelse(fitted.results > 0.5,1,0)
fitted.results_conf <- factor(fitted.results)

library(caret)
cf <- confusionMatrix(fitted.results_conf, testingN$Status, positive = "1")
cf

# Accuracy : 0.711
# Kappa : 0.407 
# Model is quite bad, the relativeljy high accurancy, is primarly due to the class imbalance between
# Empty and Occupied. As highlighted by the Kappa, the model has almost none predictive power.

library(ggplot2)
library(pROC)
?roc
logit <- roc(testingN$Status, fitted.results)
rf <- roc(testingN$Status, rf_predict1[,2])

#rocobj1 <- roc(df$actualoutcome1, data$prediction1)
#rocobj2 <- roc(df$actualoutcome1, data$prediction2)

ggroc(list(Logit = logit, Random_Forest = rf))

# # # # # # # # # # # # # # 
#           C50           #
# # # # # # # # # # # # # # 

###### Basic 
library(C50)
cFifty <- C5.0(Status ~ ., data=trainingN, trials=10)
# plot(cFifty)
# summary(cFifty) 

library(caret)
c <- predict(cFifty, testingN[, -2])
c1 <- predict(cFifty , testingN[, -2], type="prob")
c1
?predict
caret::confusionMatrix(c, testingN$Status, positive="1")

# Accuracy : 0.8081
# Kappa : 0.4137  
# Accuracy improved, but most imprtantly, kappa has largely improved, but is still quite low.

library(pROC)


library(ggplot2)
library(pROC)
?roc
logit <- roc(testingN$Status, fitted.results)
rf <- roc(testingN$Status, rf_predict1[,2])
c50roc <- roc(testingN$Status, c1[,2])

ggroc(list(Logit = logit, Random_Forest = rf, C50 = c50roc))

###### Winnowing

cFiftyWinnow <- C5.0(Status ~ ., data=trainingN, control = C5.0Control(winnow = TRUE))
cw <-  predict(cFiftyWinnow, testingN[, -2])
caret::confusionMatrix(cw, testingN$Status, positive="1")

# Accuracy : 0.8181
# Kappa : 0.4256


###### Tuning

library(caret)
tuneParams <- trainControl(
  method = "cv",
  number = 10,
  savePredictions = "final")

c50Tree <- train(trainingN[,-c(2)], trainingN$Status, method="C5.0", trControl=tuneParams, tuneLength=3)
c50.pred <- predict(c50Tree, newdata = testingN[,-c(2)])
c50.pred1 <- predict(c50Tree, newdata = testingN[,-c(2)], type="prob")
confusionMatrix(c50.pred, testingN$Status,  positive="1")

# Accuracy : 0.7776   
# Kappa : 0.542 

logit <- roc(testingN$Status, fitted.results)
rf <- roc(testingN$Status, rf_predict1[,2])
c50roc <- roc(testingN$Status, c1[,2])
c50tuningroc <- roc(testingN$Status, c50.pred1[,2])

ggroc(list(Logit = logit, Random_Forest = rf, C50 = c50roc, C50_Tuning = c50tuningroc))



########## KNN ###############

library(dummies)

str(model_data_norm)
sapply(model_data_norm,function(x) sum(is.na(x))) # There are no NA rows
model_kNN <- dummy.data.frame(model_data_norm[, -2]) # remove Status and use dummy
Status <- model_data_norm$Status


set.seed(18142923)
kNNindex <- sample(1:dim(model_kNN)[1], dim(model_kNN )[1] * .75, replace=FALSE)
kNNtraining <- model_kNN[kNNindex, ]
kNNtesting <- model_kNN[-kNNindex, ]
statusTraining <- Status[kNNindex]
statusTesting <- Status[-kNNindex]