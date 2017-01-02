install.packages("plyr")
library("plyr")
install.packages("reshape2")
library("reshape2")

## Download Zip Data
fileName <- "get_data.zip"
if (!file.exists(fileName)){
        fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl, fileName)
        unzip(fileName)
}

## Get Labels and Features
Activity_Labels <- read.table("UCI HAR Dataset/activity_labels.txt")
Activity_Labels[,2] <- as.character(Activity_Labels[,2])
Features <- read.table("UCI HAR Dataset/features.txt")
Features[,2] <- as.character(Features[,2])

## Get Mean and Standard Deviation Data
Features_M_SD <- grep(".*mean.* | .*std.*",Features[,2])
Features_M_SD_Names <- Features[Features_M_SD,2]
Features_M_SD_Names = gsub('-mean', 'Mean', Features_M_SD_Names)
Features_M_SD_Names = gsub('-std', 'Std', Features_M_SD_Names)
Features_M_SD_Names <- gsub('[-()]', '', Features_M_SD_Names)

## Get Data
Train <- read.table("UCI HAR Dataset/train/X_train.txt")[Features_M_SD]
Train_Activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
Train_Subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
Final_Train <- cbind(Train_Subjects, Train_Activities, Train)

Test <- read.table("UCI HAR Dataset/test/X_test.txt")[Features_M_SD]
Test_Activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
Test_Subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
Final_Test <- cbind(Test_Subjects, Test_Activities, Test)

## Merge Data and Labels
Final_Data <- rbind(Final_Train, Final_Test)
colnames(Final_Data) <- c("Subject", "Activity", Features_M_SD_Names)

## Melt Data
Final_Data$Activity <- factor(Final_Data$Activity, levels = Activity_Labels[,1], labels = Activity_Labels[,2])
Final_Data$Subject <- as.factor(Final_Data$Subject)

Final_Data_Melt <- melt(Final_Data, id = c("Subject", "Activity"))
Final_Data_Mean <- dcast(Final_Data_Melt, Subject + Activity ~ variable, mean)

write.table(Final_Data_Mean, "tidy.txt", row.names = FALSE, quote = FALSE)
