
# This script uses the data set loacated at https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip.  
# it is assumed that the script has been downloaded and extracted into the session's working directory.

if (file.exists("UCI HAR Dataset")) {
    setwd("./UCI HAR Dataset")    
}else {
    cat("The Directory \"UCI HAR Dataset\" does not exist. Please extract the archive into your working directory. \n")
    cat("The file can be downloaded at https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip.")
    
}

library("data.table")

# Read feature label data set.  This will be used to assign column names to the feature labels.
feature.labels.tmp <- read.table("features.txt", sep=" ",header=FALSE, col.names=c("feature.id","feature.vector"))
activity.labels.tmp<-read.table("activity_labels.txt", sep=" ",header=FALSE, col.names=c("activity.id","activity.name"))

#Correct one misnamed variable.
feature.labels.tmp$feature.vector <- gsub("BodyBody", "Body", feature.labels.tmp$feature.vector)

# Convert labes to more readable syntactically valid names.
feature.labels.tmp$feature.vector <- make.names(gsub("\\(|\\)","",feature.labels.tmp$feature.vector))
activity.labels.tmp$activity.name <- make.names(activity.labels.tmp$activity.name)

# Read activities data set into a temporary data frame.
activities.test.tmp <- read.table("test/y_test.txt",header=FALSE,  colClasses = "integer", col.names=c("activity.id"))
activities.train.tmp <- read.table("train/y_train.txt",header=FALSE,  colClasses = "integer", col.names=c("activity.id"))

# Read test and train subjects data set
subjects.test.tmp <- read.table("test/subject_test.txt",header=FALSE,  col.names=c("subject.id"))
subjects.train.tmp <- read.table("train/subject_train.txt",header=FALSE,  col.names=c("subject.id"))

# Read features test and train data set.
measures.test.tmp <- read.table("test/X_test.txt",header=FALSE,  colClasses = "numeric", col.names=feature.labels.tmp$feature.vector)
measures.train.tmp <- read.table("train/X_train.txt",header=FALSE,  colClasses = "numeric", col.names=feature.labels.tmp$feature.vector)

# Combine the subjects column, activity column, along with the measures columns.
test.set.tmp <- cbind(subjects.test.tmp, activities.test.tmp,measures.test.tmp[,grepl( "(mean|std)", feature.labels.tmp$feature.vector)])
train.set.tmp <- cbind(subjects.train.tmp, activities.train.tmp,measures.train.tmp[,grepl( "(mean|std)", feature.labels.tmp$feature.vector)])

# Merge the full test and train data sets into a single data set.
full.set <- as.data.table(rbind(test.set.tmp,train.set.tmp))

# Add the activity labels to the full data set based on the activty id.
full.set <- merge(full.set,activity.labels.tmp, by="activity.id")

# Remove the activity.id column, it's not needed in the final data set.
full.set <-subset(full.set, select =-c(activity.id))

#remove all temporary data sets
rm(list=ls(pattern=".tmp"))

# Summarize the full data set by taking averages of all measurements on the subject id and activity name.
# This in effect creates the "tidy" data set.
tidy.set <- aggregate(. ~ subject.id + activity.name , data = full.set, mean)

setwd("..") 
# Write tidy data set to file.
write.csv(tidy.set, "tidyset.csv")

