require(data.table)
require(reshape2)
require(dplyr)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
    download.file(fileURL, filename, method="curl")
}  

unzip(filename) 

# Load train and test dataset

features <- read.table("UCI HAR Dataset/features.txt", 
                       col.names = c("n","functions"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", 
                         col.names = c("code", "activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", 
                           col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", 
                     col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", 
                     col.names = "code")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", 
                            col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", 
                      col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", 
                      col.names = "code")

# Bind dataframes

x <- x_train %>% 
            bind_rows(x_test)
y <- y_train %>% 
            bind_rows(y_test)
subject <- subject_train %>% 
            bind_rows(subject_test)

data_complete <- subject %>% 
                    bind_cols(y) %>% 
                    bind_cols(x)

data_tidy <- data_complete %>% 
                select(subject, code, contains("mean"), contains("std"))

# rename the activities in the data set
data_tidy$code <- activities[data_tidy$code, 2]

# rename each column of the dataframe
names(data_tidy)[2] = "activity"
names(data_tidy)<-gsub("Acc", "Accelerometer", names(data_tidy))
names(data_tidy)<-gsub("Gyro", "Gyroscope", names(data_tidy))
names(data_tidy)<-gsub("BodyBody", "Body", names(data_tidy))
names(data_tidy)<-gsub("Mag", "Magnitude", names(data_tidy))
names(data_tidy)<-gsub("^t", "Time", names(data_tidy))
names(data_tidy)<-gsub("^f", "Frequency", names(data_tidy))
names(data_tidy)<-gsub("tBody", "TimeBody", names(data_tidy))
names(data_tidy)<-gsub("-mean()", "Mean", names(data_tidy), ignore.case = TRUE)
names(data_tidy)<-gsub("-std()", "STD", names(data_tidy), ignore.case = TRUE)
names(data_tidy)<-gsub("-freq()", "Frequency", names(data_tidy), ignore.case = TRUE)
names(data_tidy)<-gsub("angle", "Angle", names(data_tidy))
names(data_tidy)<-gsub("gravity", "Gravity", names(data_tidy))

head(data_tidy)

# mean all the colums grouped by subject and activity
data_results <- data_tidy %>%
                group_by(subject, activity) %>%
                summarise_all(list(mean))


write.table(data_results, "tidy_data.txt", row.name=FALSE)
