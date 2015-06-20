library("dplyr")
library("reshape2")



# LOAD the lookup tables - features and activities

##setwd("~/Coursera-Data-Science/03 Getting and Cleaning Data/Course Project/UCI HAR Dataset")

        #Gives us our labels for 561 variables.
        features <- read.table("features.txt", as.is = TRUE)
        features <- rename(features, colLabels = V2)
        # pull only the features with the word "mean" or "std"
        selectFeatures <- features[which(grepl("mean|std",features$colLabels)),]

        # Gives us our labels for activities 1 through 6.
        activity_labels <- read.table("activity_labels.txt", as.is = TRUE)
        activity_labels <- rename(activity_labels, Act.Code = V1, Act.Desc = V2)


        
# LOAD the training data
        
##setwd("~/Coursera-Data-Science/03 Getting and Cleaning Data/Course Project/UCI HAR Dataset/train")

        sTrain <- read.csv("subject_train.txt", header = FALSE)
                sTrain <- rename(sTrain, Subject = V1)

        xTrain <- read.table("X_train.txt", col.names = features$colLabels)
        xTrain <- select(xTrain, selectFeatures$V1)
        
        yTrain <- read.csv("y_train.txt", header = FALSE)
        yTrain <- rename(yTrain, Act.Code = V1)
        yTrain <- merge(
                yTrain, activity_labels, 
                by = "Act.Code", sort = FALSE)

        train <- cbind(sTrain, yTrain, xTrain)
        train$Source <- "Train"



        
# LOAD the testing data.
        
##setwd("~/Coursera-Data-Science/03 Getting and Cleaning Data/Course Project/UCI HAR Dataset/test")
        
        sTest <- read.csv("subject_test.txt", header = FALSE)
        sTest <- rename(sTest, Subject = V1)
        
        xTest <- read.table("X_test.txt", col.names = features$colLabels)
        xTest <- select(xTest, selectFeatures$V1)
        
        yTest <- read.csv("y_test.txt", header = FALSE)
        yTest <- rename(yTest, Act.Code = V1)
        yTest <- merge(
                yTest, activity_labels, 
                by = "Act.Code", sort = FALSE)
        
        test <- cbind(sTest, yTest, xTest)
        test$Source <- "Test"
        
        
        
        
# Combine the train and test datasets and do some sorting.        

mergedFile <- rbind(train, test)
mergedFile <- arrange(mergedFile, Act.Code, Subject)


# Convert the data frame to a long format to help with later computations.

meltFile <- melt(
        mergedFile, id.vars = c("Subject", "Act.Code", "Act.Desc", "Source"))

# Perform summarization.

tidy_df <- summarize(
        group_by(
                meltFile, Act.Code, Subject, variable), 
        mean(value))

# Write the file to destination

## setwd("~/Coursera-Data-Science/03 Getting and Cleaning Data/Course Project")
        
        write.table(tidy_df, "tidy_file.txt", row.names = FALSE)
