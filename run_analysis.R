library(tidyr)
library(tidyverse)
library(dplyr)

# We set wd were the source code is it, then the files are downloaded
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
link_zip <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(link_zip, destfile = "./data.zip")
dir.create('./data')
unzip("./data.zip", exdir = "./data")
setwd("./data/UCI HAR Dataset")

# Step 1, We merge train and test set on one dataframe
file_path <- "./test/X_test.txt"
x_test<- read.table(file_path, header = FALSE)
file_path <- "./test/subject_test.txt"
subject<- read.table(file_path, header = FALSE)
file_path <- "./test/Y_test.txt"
y_test<- read.table(file_path, header = FALSE)
#colnames(y_test) <- "activity"
data_test <- cbind(x_test,subject,y_test)

# Train
file_path <- "./train/X_train.txt"
x_train<- read.table(file_path, header = FALSE)
file_path <- "./train/subject_train.txt"
subject<- read.table(file_path, header = FALSE)
file_path <- "./train/Y_train.txt"
y_train<- read.table(file_path, header = FALSE)
#colnames(y_train) <- "activity"
data_train <- cbind(x_train,subject,y_train)
data <- rbind(data_test,data_train)

# Headers dataframe
file_path <- "./features.txt"
data_head<- read.table(file_path, header = FALSE)
names <- c(data_head[,2],"subject",'activity')
colnames(data) <- names

# Step 2, We obtain the mean and std for every measure with mean or std in his name
dataFiltered <- data[,grep("mean|std|activity|subject", names(data), ignore.case=T)]

# Step 3, use descriptive names on activity column
file_path <- "./activity_labels.txt"
labels<- read.table(file_path, header = FALSE)
dataFiltered$activity_name <- lapply(dataFiltered$activity,function(x) labels[x,2])

# Step 4, 
# Tidying the headers
headers <- lapply(colnames(dataFiltered),function(x) gsub("\\()","",x))
headers <- lapply(headers,function(x) gsub("-","",x))
headers
colnames(dataFiltered) <- headers
#view(dataFiltered)

# Step 5
dfGrouped <- aggregate(dataFiltered[,1:88], by=list(dataFiltered$activity,dataFiltered$subject), FUN=mean)
dfTidy    <- dfGrouped[,1:88]
colnames(dfTidy)[colnames(dfTidy) == 'Group.1'] <- "Activity"
colnames(dfTidy)[colnames(dfTidy) == 'Group.2'] <- "Subject"
dfTidy$Activity <- lapply(dfTidy$Activity,function(x) labels[x,2])
  
view(dfTidy)
# We save the data
# We save the data
setwd("../..")
dfTidy <- apply(dfTidy,2,as.character)
write.table(dfTidy,file = "tidy.txt",row.names = FALSE)
