################################################################################
# Title: Getting and Cleaning Data > Week 4 > Course Project
# Writer: KyungJin Sohn
# Date : 07.19.2021
################################################################################

### 0. Download the data for the project
if (!file.exists("./data/HAR.zip")) {
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, "./data/HAR.zip", mode = "wb")
}

  # Unzip the folder
if (!dir.exists("./data/UCI HAR Dataset")) {
  unzip("./data/HAR.zip", exdir = "./data")
}


### 1. Merges the training and the test sets to create one data set
  # Load train data set and combine label and subject data
train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
train_labels <- read.table("./data/UCI HAR Dataset/train/y_train.txt",
                           col.names = c("label"))
train_subject<- read.table("./data/UCI HAR Dataset/train/subject_train.txt",
                           col.names = c("subject"))
train <- cbind(train_subject, train_labels, train)

  # Load test data set and combine label and subject data
test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
test_labels <- read.table("./data/UCI HAR Dataset/test/y_test.txt",
                          col.names = c("label"))
test_subject <- read.table("./data/UCI HAR Dataset/test/subject_test.txt",
                            col.names = c("subject"))
test <- cbind(test_labels, test_subject, test)

  # Merge the two sets
HAR <- rbind(train, test)


### 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
  # Load feature data set
features <- read.table("./data/UCI HAR Dataset/features.txt",
                       col.names = c("index", "feature"))
mean_std_index <- grep("*(mean|std)()*", features$feature)

  # Extract only the necessary measurements
HAR <- HAR[, c(1, 2, mean_std_index + 2)]


### 3. Uses descriptive activity names to name the activities in the data set
  # Load activity data set
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt",
                              col.names = c("index", "activity"))

  # Change labels to matching activity names
HAR$label <- factor(HAR$label, levels = activity_labels$index, 
                            labels = activity_labels$activity)
colnames(HAR)[2] <- "acitivity"


### 4. Appropriately labels the data set with descriptive variable names. 
  # Change column name to matching variable names
colnames(HAR)[3:ncol(HAR)] <- features$feature[mean_std_index]


### 5. From the data set in step 4, creates a second, independent tidy data set 
###    with the average of each variable for each activity and each subject.
library(dplyr)
tidy_data <- HAR %>% group_by(subject, acitivity) %>% 
  summarise(across(everything(), list(mean)))

write.table(tidy_data, "./data/tidy_data.txt")
