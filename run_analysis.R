features <- fread("./features.txt")
x_test <- fread("./test/X_test.txt")
y_test <- fread("./test/y_test.txt")
x_train <- fread("./train/X_train.txt")
y_train <- fread("./train/y_train.txt")
test_subject <- fread("./test/subject_test.txt")
train_subject <- fread("./train/subject_train.txt")
#code above loads in all necessary files
feature_title <- features$V2
#pulls just the feature names from the features table
feature_names <- feature_title[grep("mean|std", feature_title)]
feature_names <- gsub("\\()", "", feature_names)
#these pull only names with mean or std in the title, also removing "()" from 
#the title
x_test_sub <- select(x_test, all_of(grep("mean|std", feature_title)))
x_train_sub <- select(x_train, all_of(grep("mean|std", feature_title)))
#this filters out the non-mean/std columns from the test and train datasets
colnames(x_test_sub) <- feature_names
colnames(x_train_sub) <- feature_names
#this adds the column names to the test and train datasets
test_master <- cbind(y_test, test_subject, x_test_sub)
experiment <- "test"
test_master <- cbind(experiment, test_master)
train_master <- cbind(y_train, train_subject, x_train_sub)
experiment <- "train"
train_master <- cbind(experiment, train_master)
#the above column binds the activity code, subject, and data tables together.
#it also adds a column to designate whether the sample was from the training or
#test set.
master <- rbind(test_master, train_master)
#row binds the training and test datasets
master <- rename(master, "activity" = c(2), "subject" = c(3))
#adds column names to the activity and subject columns
master <- select(master, -grep("meanFreq", names(master)))
#removes the "meanFreq" data from the master dataset
master$activity <- as.character(master$activity)
master$activity <- recode(master$activity, "1" = "walking", "2" = "walkingup", 
                          "3" = "walkingdown", "4" = "sitting", "5" = "standing", 
                          "6" = "laying")
## The codes above exchange the activity numbers with descriptive terms for the
#activities. The "master" dataset contains the combined dataset for 
#each mean and std variable from the training and test datasets.
rm(features, test_master, test_subject, train_master, train_subject, x_test,
   x_test_sub, x_train, x_train_sub, y_test, y_train)
tidym <-master %>%
  select(-experiment) %>%
  group_by(activity, subject) %>%
  summarise_all("mean")
#the tidym dataset returns the average for each variable for each activity and
#each subject.
