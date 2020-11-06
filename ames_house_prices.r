# I didn't have any saved R code from my undergraduate courses or my previous job so I wrote some brief code using
# this dataset on houses in Ames, Iowa: https://www.kaggle.com/c/house-prices-advanced-regression-techniques/overview

# install.packages('caTools')
library(caTools)
# install.packages('Metrics')
library(Metrics)

# Import data
data <- read.csv("C:\\Users\\paulo\\Documents\\house-prices-advanced-regression-techniques\\train.csv")

split = sample.split(data$SalePrice, SplitRatio = 0.8)
training_set = subset(data, split == TRUE)
test_set = subset(data, split == FALSE)

# Look at variable list
ls(training_set)

# Histogram of target variable
hist(training_set$SalePrice)

# Summary of Different Important Explanatory Variables
summary(training_set$LotArea)
summary(training_set$YearBuilt)
summary(training_set$BedroomAbvGr)
summary(training_set$FullBath)
summary(training_set$HalfBath)
unique(training_set$MSZoning)
unique(training_set$Utilities)
unique(training_set$Neighborhood)
unique(training_set$BldgType)

# Visualizing some relationships
plot(density(log(training_set$SalePrice)))
plot(training_set$SalePrice,training_set$LotArea)
plot(training_set$SalePrice,log(training_set$LotArea))
plot(log(training_set$SalePrice),log(training_set$LotArea))

plot(training_set$SalePrice,training_set$YearBuilt)
plot(log(training_set$SalePrice),training_set$YearBuilt)

plot(training_set$SalePrice, training_set$BedroomAbvGr)

# Some data transformations
training_set$SumBath <- training_set$FullBath + 0.5*training_set$HalfBath
test_set$SumBath <- test_set$FullBath + 0.5*test_set$HalfBath

# Check Correlations
cor(training_set$SalePrice, training_set$YearBuilt)
cor(training_set$SalePrice, training_set$BedroomAbvGr)
cor(training_set$SalePrice, training_set$SumBath)
cor(training_set$BedroomAbvGr, training_set$SumBath)

# Linear Regressions
linearMod1 <- lm(log(SalePrice) ~ YearBuilt, data = training_set)
linearMod2 <- lm(log(SalePrice) ~ SumBath, data = training_set)
linearMod3 <- lm(log(SalePrice) ~ YearBuilt + SumBath, data = training_set)
summary(linearMod1)
summary(linearMod2)
summary(linearMod3)

lM3_resid <- resid(linearMod3)
plot(lM3_resid,training_set$YearBuilt)
plot(lM3_resid,training_set$SumBath)

# Creating predictions
lM3_pred <- predict(linearMod3)
plot(lM3_pred,log(training_set$SalePrice))

test_pred <- predict(linearMod3, test_set)
plot(test_pred,log(test_set$SalePrice))
plot(exp(test_pred),test_set$SalePrice)

# Evaluation Statistics
mape(test_pred,log(test_set$SalePrice))
mape(exp(test_pred),test_set$SalePrice)
