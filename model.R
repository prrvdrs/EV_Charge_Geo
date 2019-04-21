
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

# Hypothesis

# Using a subset of the data

model_data <- data %>% filter(Year == '2019') %>% filter(Month == 'March')

table(model_data$Status) # Three types: Empty, Occ and Part. Handeling Part as Occ

model_data$Status <- ifelse(grepl("Occ", model_data$Status), "Occ",
                            ifelse(grepl("Part", model_data$Status), "Occ",
                                   "Empty"))

model_data$Status <- factor(model_data$Status, levels = c("Empty","Occ"), labels = c("0",	"1"))
table(model_data$Status)


model_data <- data.frame(model_data)

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
caret::confusionMatrix(rf_predict, testing$Status, positive="1")

# Accuracy : 0.8177
# Kappa : 0.4814 

# Trying to plot ROC graph
# library(pROC)

#rf_response_scores <- predict(rf, testing, type="response")
# plot(roc(testing$Status, rf_predict, direction="<"),
#     col="yellow", lwd=3, main="The turtle finds its way")


# # # # # # # # # # # # # # 
#       Logit Model       #
# # # # # # # # # # # # # # 


mylogit <- glm(Status ~ ., data = trainingN, family = "binomial")
summary(mylogit)

anova(mylogit, test="Chisq")

fitted.results <- predict(mylogit,newdata=testingN,type='response')
fitted.results <- ifelse(fitted.results > 0.5,1,0)
fitted.results <- factor(fitted.results)

library(caret)
cf <- confusionMatrix(fitted.results, testingN$Status, positive = "1")
cf


# Accuracy : 0.7734
# Kappa : 0.262  
# Model is quite bad, the relativeljy high accurancy, is primarly due to the class imbalance between
# Empty and Occupied. As highlighted by the Kappa, the model has almost none predictive power.


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
caret::confusionMatrix(c, testingN$Status, positive="1")

# Accuracy : 0.8081
# Kappa : 0.4137  
# Accuracy improved, but most imprtantly, kappa has largely improved, but is still quite low.


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
confusionMatrix(c50.pred, testingN$Status,  positive="1")


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

# Let’s choose some values of k:
k1 <- round(sqrt(dim(training)[1])) #sqrt of number of instances
k2 <- round(sqrt(dim(training)[2])) #sqrt of number of attributes
k3 <- 7 #a number between 3 and 10
# Feel free to add in more too! Now, run kNN:

library(class)
#knn1 <- knn(train = kNNtraining, test = kNNtesting, cl = statusTraining, k=k1)
knn2 <- knn(train = kNNtraining, test = kNNtesting, cl = statusTraining, k=k2)
knn3 <- knn(train = kNNtraining, test = kNNtesting, cl = statusTraining, k=k3)

#auc(survivedTest, knn1)
auc(survivedTest, knn2)
auc(survivedTest, knn3)
# Differences may also be due to sampling, hence doing Cross validation, andtaking the average auc.

library(ModelMetrics)
library(class)
# Cross-validation
folds <- createFolds(Survived, k = 10) # Train the model multiple time, on different training and testing data. 10 is a best practice.
cv_results <- lapply(folds, function(x) {
  knn_train <- tkNN[x, ]
  knn_test <- tkNN[-x, ]
  survivedTrain <- Survived[x]
  survivedTest <- Survived[-x]
  knn_model <- knn(train = knn_train, test = knn_test, cl = survivedTrain, k=3)
  a <- auc(survivedTest, knn_model)
  return(a)
})
auroc <- unlist(cv_results)
summary(auroc)
# Take the mean

# mean auc k1 0.6933
# mean auc k2 0.7624
# mean auc k3 0.7531

#############################################
# define training control parameters        #
# find bes k in terms of Accuracy and Kappa

# https://machinelearningmastery.com/how-to-estimate-model-accuracy-in-r-using-the-caret-package/
train_control <- trainControl(method="cv", number=10) # cv is cross-validation
model <- train(y=Survived, x=tkNN, trControl=train_control, method="knn")
print(model)

# Task 6:

# Find best k in terms of AUROC
perf <- c()
folds <- createFolds(Survived, k = 10)
for (i in 1:30) {
  cv_results <- lapply(folds, function(x) {
    knn_train <- tkNN[x, ]
    knn_test <- tkNN[-x, ]
    survivedTrain <- Survived[x]
    survivedTest <- Survived[-x]
    knn_model <- knn(train = knn_train, test = knn_test, cl = survivedTrain, k=i)
    a <- auc(survivedTest, knn_model)
    return(a)
  })
  perf[i] <- mean(unlist(cv_results))
}
plot(perf, xlab="k", ylab="AUROC")



