README - Getting and Cleaning Data Course Project
========================================================

This repository contains R scripts that create a data set with the average average all measurements along the standard deviation and mean from the Human Activity Recognition Using Smartphones Dataset Version 1.0 by each subject and activity.

The data set used for this analysis was composed of 10299 measurements of 561 variables (aka."features").  These were estimated from the raw signals generated by the accelerometer and gyroscope of the Samsung Galaxy S II smartphone that each of the subjects were required to wear while the experiments were carried out. 

Details about this data set can be obtained at the following url:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

The data for this project can be obtained at the following url:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

Both the README.txt and features_info.txt files contain further details about the experiments.  

The goal of this analysis is to do the following:  
  
1) Merge the test and train data sets.    
2) Extract all measurements on the standard deviation and mean from the source file.  
3) Convert variable (column) names into syntactically correct names.  
4) Calculate the mean of each variable across the subject and activity.  
 
The following files were used for this analysis.
- 'features.txt': List of all features.  
- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30.   
- 'test/subject_test.txt' : Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30.   
- 'activity_labels.txt': Links the class labels with their activity name.  
- 'train/X_train.txt': Training set.  
- 'train/y_train.txt': Training labels.  
- 'test/X_test.txt': Test set.  
- 'test/y_test.txt': Test labels.  

Files in this repository
--------------------
* README.md - Markdown for this file.  
* CodeBook.md - Markdown file describing the tidyset.csv file.  
* run_analysis.md - The R script that creates tidyset.csv.  

Instructions for running this analysis
-------------
1. Prior to the exectuion the working directory should be set to the same directory in which the data set has been extracted.  The script expects to find the "UCI HAR Dataset" directory.  If this does not exist, you will be instructed to download the data set and set the working directory.
2. Execute the run_analysis.R script.
3. The file tidyset.csv will be generated.  

* Please note. If package memisc is loaded, please make sure that you unload this package first.  The aggregate function is redefined in this pacakage and is not compatible with this script.

Transformations
------------------------------

#### 1. Clean column names

The features.txt and activity_labels.txt were read into a data frame.  For the features.txt file, it was necessary to remove open and close parenthesis first using the gsub function.  Next, the labels from both files were then converted to be more readable and syntactically valid names using the make.names function.  (Note: the values in the activity_labels.txt file did not change.)  The feature labels data set will be assigned to the variable names when the X_train.txt and X_test.txt files are read.
```
# Convert labels to more readable syntactically valid names.
feature.labels.tmp$feature.vector <- make.names(gsub("\\(|\\)","",feature.labels.tmp$feature.vector))
activity.labels.tmp$activity.name <- make.names(activity.labels.tmp$activity.name)

```
#### 2. Combine the subjects , activities , and measures data sets into a single test and train data set.   

For the measures data set, only variables on the mean and standard deviation were extracted.  This was performed by using the grepl function to match the pattern of "mean" or "std" in the feature.labels.tmp$feature.vector vector.  This subset of the measurement data was then combined with the subjects and activities data sets.
```
# Combine the subjects column, activity column, along with the measures columns.
test.set.tmp <- cbind(subjects.test.tmp, activities.test.tmp,measures.test.tmp[,grepl( "(mean|std)", feature.labels.tmp$feature.vector)])
train.set.tmp <- cbind(subjects.train.tmp, activities.train.tmp,measures.train.tmp[,grepl( "(mean|std)", feature.labels.tmp$feature.vector)])
```
#### 3. Merge the test and train data set into a single data set.
```
# Merge the full test and train data sets into a single data set.
full.set <- as.data.table(rbind(test.set.tmp,train.set.tmp))
```
#### 4. Add the activity identifer label to this data set
This was done performed using the merge function below.
```
# Add the activity labels to the full data set based on the activty id.
full.set <- merge(full.set,activity.labels.tmp, by="activity.id")
```
#### 5. Remove the activity.id column, it's not needed in the final data set.
```
# Remove the activity.id column, it's not needed in the final data set.
full.set <-subset(full.set, select =-c(activity.id))
```
#### 6. Summarize the data set

Use the aggregate function to calculate the mean of each varaiable by subject and activity.  This will create a data set with 180 rows.  (Assuming each subject performed each activity. in the experiment)
```
# Summarize the full data set by taking averages of all measurements on the subject id and activity name.
# This in effect creates the "tidy" data set.
tidy.set <- aggregate(.  ~ subject.id + activity.name , data = full.set, mean)
```






