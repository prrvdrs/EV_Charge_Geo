
# Open data: January 2018 to March 2019

data <- read.csv("C:/Users/pierr/Documents/Projects/EV_Charge_Geo/data/evcp_main_all.csv", header= TRUE) # may take a couple of seconds to laod.

# Setup

library(dplyr)
library(tidyr)
library(data.table)

setDT(data) # Transforms data.frame to data.table which is more effiecent when hadeling 6 Million rows.
str(data)
data <- data[,-c(1,3)] # drop index columns
data$Hour <- factor(data$Hour)
data$Year <- factor(data$Year)


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

model_data <- data

table(model_data$Status) # Three types: Empty, Occ and Part. Handeling Part as Occ

model_data$Status <- ifelse(grepl("Occ", model_data$Status), "Occ",
                            ifelse(grepl("Part", model_data$Status), "Occ",
                                   "Empty"))

model_data$Status <- factor(model_data$Status, levels = c("Empty","Occ"), labels = c("0",	"1"))
table(model_data$Status)


# Normalization
model_data <- data.frame(model_data)

num <- sapply(model_data, function(x) {is.numeric(x)}) # Get Numerics
model_numeric <- model_data[, num]
summary(model_numeric)

normalize <- function(x) { return ((x - min(x)) / (max(x) - min(x))) }
model_numeric_normal <- normalize(model_numeric)
summary(model_numeric_normal)

model_categorical <- model_data[, !num]

model_data_norm <- cbind(model_categorical,model_numeric_normal)

setDT(model_data_norm)


# Training and Testing Data

set.seed(18142923)
index <- sample(1:dim(model_data_norm)[1], dim(model_data_norm )[1] * .75, replace=FALSE)
training <- model_data_norm[index, ]
testing <- model_data_norm[-index, ]


# Logit Model

memory.limit()
memory.limit(size=56000)

mylogit <- glm(Status ~ Hour + Weekday + County + Poi + Shopping, data = training, family = "binomial")
summary(mylogit)

anova(mylogit, test="Chisq")


