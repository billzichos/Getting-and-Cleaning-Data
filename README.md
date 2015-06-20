#README - Getting and Cleaning Data Course Project

##Summary

Use the run_analysis.R file to process the Samsung Galaxy accelerometer data.

We have the following training and testing information:

- Accelerometer measurements (X_train.txt, X_test.txt)
- A file describing the person generating the measurements (subject_train.txt, subject_test.txt)
- A file describing the activity the person was doing when generating the measurements (y_train.txt, y_test.txt)

We also have a file of labels for the Accelerometer measurements - features.txt

We also have a file to serve as a lookup for the activity codes - activity_labels.txt

The goal is to organize these files so that we can eventually start analyzing.  The details below describe the approach used to do this.

For questions, contact [Bill](mailto:bill.zichos@hotmail.com).

##Details

###Libraries

The following libraries were leveraged in this program.

- dplyr
- reshape2

###Program Flow

1. I start by loading in the ancillary tables - features and activities.  I use the read.table() function, which seems to load this data well with few parameters.

        #Gives us our labels for 561 variables.
        features <- read.table("features.txt", as.is = TRUE)
        features <- rename(features, colLabels = V2)
        # pull only the features with the word "mean" or "std"
        selectFeatures <- features[which(grepl("mean|std",features$colLabels)),]

        # Gives us our labels for activities 1 through 6.
        activity_labels <- read.table("activity_labels.txt", as.is = TRUE)
        activity_labels <- rename(activity_labels, Act.Code = V1, Act.Desc = V2)
        
2. Load the training and testing data using the same process.  Repeating this code for both sets is probably avoidable with some kind of loop, but for now, the same code as below is repeated for the test dataset.

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

Note that this will likely be used in some kind of data mining task, so it is likely helpful that we have a way to tell the difference between our training and test data once it has been combined.  Therefore, I like to do the following.

        train$Source <- "Train"

3. Combine the train and test datasets and do some sorting.        

        mergedFile <- rbind(train, test)
        mergedFile <- arrange(mergedFile, Act.Code, Subject)

4. Convert the data frame to a long format to help with later computations.

        meltFile <- melt(
                mergedFile, id.vars = c("Subject", "Act.Code", "Act.Desc", "Source"))

5. Perform summarization - an average of each variable for each activity and each subject.

        tidy_df <- summarize(
                group_by(
                        meltFile, Act.Code, Subject, variable), 
                mean(value))

6. Write the resulting file to current working directory.
        
        write.table(tidy_df, "tidy_file.txt", row.names = FALSE)