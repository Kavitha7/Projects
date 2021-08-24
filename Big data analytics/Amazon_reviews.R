
#------------------------------ANALYSING AMAZON REVIEWS ---------------------------------------------------------------------------------------------------------------------- 

## Business objective:
# The objective is to start a new product line by selecting a product from three product categories.
# Three product categories are Movies and Tv, Cds and Vinyl and Kindle store.
# The product that has larger market size with good customer reviews and the product that is heavily purchased is the ideal category to invest in.

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Load the following library.

library(SparkR)

## Initialising SparkR.

sc <- sparkR.session(appName = "demo", enableHiveSupport = TRUE)

## Reading following data sets that are stored in s3 using read.df().

movies_and_tv_df <- read.df("s3n://bigdatacasestudy/reviews_Movies_and_TV_5.json", source = "json", inferSchema = "true", header = "true")

cds_and_vinyl_df <- read.df("s3n://bigdatacasestudy/reviews_CDs_and_Vinyl_5.json", source = "json", inferSchema = "true", header = "true")

kindle_store_df <- read.df("s3n://bigdatacasestudy/reviews_Kindle_Store_5.json", source = "json", inferSchema = "true", header = "true")

# Examining structure of SparkR dataframes.

movies_and_tv_df

cds_and_vinyl_df

kindle_store_df

# Examining the size of SparkR dataframes.

nrow(movies_and_tv_df) 

nrow(cds_and_vinyl_df) 

nrow(kindle_store_df)  

ncol(movies_and_tv_df)

ncol(cds_and_vinyl_df)

ncol(kindle_store_df)

# Viewing first few rows of every dataframe.

head(movies_and_tv_df)

head(cds_and_vinyl_df)

head(kindle_store_df)

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Checking every data frame for duplicates.

movies_and_tv <- unique(movies_and_tv_df)
nrow(movies_and_tv) # Number of rows = 1697533. Hence no duplicates.

cds_and_vinyl <- unique(cds_and_vinyl_df)
nrow(cds_and_vinyl) # Number of rows = 1097592. Hence no duplicates.

kindle_store <- unique(kindle_store_df)
nrow(kindle_store) # Number of rows = 982619. Hence no duplicates.

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Understanding the data by determing some summary statistics.

# Determining frequency of each reviewerID in "movies_and_tv" dataframe.

head(summarize(groupBy(movies_and_tv, movies_and_tv$reviewerID), count = n(movies_and_tv$reviewerID)))

# Determining the average rating provided by each reviewer ID in "movies_and_tv" dataframe.

head(summarize(groupBy(movies_and_tv, movies_and_tv$reviewerID), avg_rating = mean(movies_and_tv$overall)))

# Determining frequency of each reviewerID in "cds_and_vinyl" dataframe.

head(summarize(groupBy(cds_and_vinyl, cds_and_vinyl$reviewerID), count = n(cds_and_vinyl$reviewerID)))

# Determining the average rating provided by each reviewer ID in "cds_and_vinyl" dataframe.

head(summarize(groupBy(cds_and_vinyl, cds_and_vinyl$reviewerID), avg_rating = mean(cds_and_vinyl$overall)))

# Determining frequency of each reviewerID in "kindle_store" dataframe.

head(summarize(groupBy(kindle_store, kindle_store$reviewerID), count = n(kindle_store$reviewerID)))

# Determining the average rating provided by each reviewer ID in "kindle_store" dataframe.

head(summarize(groupBy(kindle_store, kindle_store$reviewerID), avg_rating = mean(kindle_store$overall)))

#-------------------------------------------------------------------------------------------------------------------------------------------------------------

## Checking which columns in "movies_and_tv" dataframe have NULL values using isNULL().

nrow(where(movies_and_tv, isNull(movies_and_tv$asin)))
nrow(where(movies_and_tv, isNull(movies_and_tv$helpful)))
nrow(where(movies_and_tv, isNull(movies_and_tv$overall)))
nrow(where(movies_and_tv, isNull(movies_and_tv$reviewText)))
nrow(where(movies_and_tv, isNull(movies_and_tv$reviewTime)))
nrow(where(movies_and_tv, isNull(movies_and_tv$reviewerID)))
nrow(where(movies_and_tv, isNull(movies_and_tv$reviewerName))) # reviewerName has 6076 Null values.
nrow(where(movies_and_tv, isNull(movies_and_tv$summary)))
nrow(where(movies_and_tv, isNull(movies_and_tv$unixReviewTime)))


# Removing NULL values from "movies_and_tv" using isNotNULL function.

movies_and_tv = filter(movies_and_tv, isNotNull(movies_and_tv$reviewerName))

# Confirming that there are no missing values.

nrow(where(movies_and_tv, isNull(movies_and_tv$reviewerName)))

# Registering "movies_and_tv" dataframe as table to apply SQL queries on it.
# This is done using createOrReplaceTempView function.

createOrReplaceTempView(movies_and_tv, "movies_and_tv")

# Extracting first and second elements of attribute "helpful" using its indices.
# helpful[0] is stored as "helpfulness" and helpful[1] is stored as "total_votes".
# Both elements of array helpful and remaining attributes are stored in "movies_with_helful_score".

movies_with_helful_score <- SparkR::sql("SELECT *, helpful[0] as helpfulness, helpful[1] as total_votes from movies_and_tv")

# Viewing first few rows of "movies_with_helful_score".

head(movies_with_helful_score)

# Filtering "movies_with_helful_score" such that helpfulness >= 10 and total_votes >10 and storing it as "filtered_on_helful".

filtered_on_helful <- filter(movies_with_helful_score, movies_with_helful_score$helpfulness>=10 & movies_with_helful_score$total_votes>10)
head(filtered_on_helful)

# Registering "filtered_on_helpful" as table to apply SQL queries on it.

createOrReplaceTempView(filtered_on_helful, "filtered_on_helful")

# Extracting length of reviewtext as "reviewtext_length" and storing as "text_length_df".

text_length_df <- SparkR::sql("SELECT *, length(reviewText) as reviewtext_length from filtered_on_helful")

head(text_length_df)

# Converting unixReviewTime from unixtime format to date-time format.

createOrReplaceTempView(text_length_df, "text_length_df")

unix_to_date <- SparkR::sql("SELECT *, from_unixtime(unixReviewTime) as timestamp from text_length_df")
head(unix_to_date)

# Storing "unix_to_date" as "movies_and_tv_final".

movies_and_tv_final <- unix_to_date

#----------------------------------------------------------------------------------------

## Checking for NULL values in "cds_and_vinyl" dataframe.

nrow(where(cds_and_vinyl, isNull(cds_and_vinyl$asin)))
nrow(where(cds_and_vinyl, isNull(cds_and_vinyl$helpful)))
nrow(where(cds_and_vinyl, isNull(cds_and_vinyl$overall)))
nrow(where(cds_and_vinyl, isNull(cds_and_vinyl$reviewText)))
nrow(where(cds_and_vinyl, isNull(cds_and_vinyl$reviewTime)))
nrow(where(cds_and_vinyl, isNull(cds_and_vinyl$reviewerID)))
nrow(where(cds_and_vinyl, isNull(cds_and_vinyl$reviewerName))) # reviewerName has 2941 Null values.
nrow(where(cds_and_vinyl, isNull(cds_and_vinyl$summary)))
nrow(where(cds_and_vinyl, isNull(cds_and_vinyl$unixReviewTime)))

# Removing NULL values from column "reviewerName".

cds_and_vinyl = filter(cds_and_vinyl, isNotNull(cds_and_vinyl$reviewerName))

# Confirming that there are no missing values.

nrow(where(cds_and_vinyl, isNull(cds_and_vinyl$reviewerName)))

# Registering table to run SQL queries.

createOrReplaceTempView(cds_and_vinyl, "cds_and_vinyl")

# Extracting first and second elements of attribute "helpful" using its indices.
# helpful[0] is stored as "helpfulness" and helpful[1] is stored as "total_votes".
# Both elements of array helpful and remaining attributes are stored in "cds_with_helpful_score".

cds_with_helpful_score <- SparkR::sql("SELECT *, helpful[0] as helpfulness, helpful[1] as total_votes from cds_and_vinyl")

# Viewing "cds_with_helpful_score" to see whether elements of "helpful" array are separated or not.

head(cds_with_helpful_score)

# Filtering "cds_with_helful_score" such that helpfulness >= 10 and total_votes >10 and storing as "cds_filtered_on_helful".

cds_filtered_on_helful <- filter(cds_with_helpful_score, cds_with_helpful_score$helpfulness>=10 & cds_with_helpful_score$total_votes>10)
head(cds_filtered_on_helful)

# Registering "cds_filtered_on_total" as table.

createOrReplaceTempView(cds_filtered_on_helful, "cds_filtered_on_helful")

# Extracting length of reviewtext as "reviewtext_length" and storing as "cds_text_length_df".

cds_text_length_df <- SparkR::sql("SELECT *, length(reviewText) as reviewtext_length from cds_filtered_on_helful")

head(cds_text_length_df)

# Converting unixReviewTime from unixtime format to date-time format.

createOrReplaceTempView(cds_text_length_df, "cds_text_length_df")

cds_unix_to_date <- SparkR::sql("SELECT *, from_unixtime(unixReviewTime) as timestamp from cds_text_length_df")
head(cds_unix_to_date)

# Storing "cds_unix_to_date" as "cds_and_vinyl_final".

cds_and_vinyl_final <- cds_unix_to_date

#---------------------------------------------------------------------------------------------------------------------

## Checking for NULL values in "kindle_store" dataframe.

nrow(where(kindle_store, isNull(kindle_store$asin)))
nrow(where(kindle_store, isNull(kindle_store$helpful)))
nrow(where(kindle_store, isNull(kindle_store$overall)))
nrow(where(kindle_store, isNull(kindle_store$reviewText)))
nrow(where(kindle_store, isNull(kindle_store$reviewTime)))
nrow(where(kindle_store, isNull(kindle_store$reviewerID)))
nrow(where(kindle_store, isNull(kindle_store$reviewerName))) # reviewerName has 3799 Null values.
nrow(where(kindle_store, isNull(kindle_store$summary)))
nrow(where(kindle_store, isNull(kindle_store$unixReviewTime)))

# Removing NULL values from column "reviewerName".

kindle_store = filter(kindle_store, isNotNull(kindle_store$reviewerName))

# Confirming that there are no missing values.

nrow(where(kindle_store, isNull(kindle_store$reviewerName)))


# Registering "kindle_store" as table to run SQL queries.

createOrReplaceTempView(kindle_store, "kindle_store")

# Extracting first and second elements of attribute "helpful" using its indices.
# helpful[0] is stored as "helpfulness" and helpful[1] is stored as "total_votes".
# Both elements of array helpful and remaining attributes are stored in "kindle_with_helpful_score".

kindle_with_helpful_score <- SparkR::sql("SELECT *, helpful[0] as helpfulness, helpful[1] as total_votes from kindle_store")

# Viewing "kindle_with_helpful_score" to see whether elements of "helpful" array are included or not.

head(kindle_with_helpful_score)

# Filtering "kindle_with_helpful_score" such that helpfulness >= 10 and storing as "kindle_filtered_on_helful".

kindle_filtered_on_helful <- filter(kindle_with_helpful_score, kindle_with_helpful_score$helpfulness>=10 & kindle_with_helpful_score$total_votes>10)
head(kindle_filtered_on_helful)

# Registering "kindle_filtered_on_helpful" as table.

createOrReplaceTempView(kindle_filtered_on_helful, "kindle_filtered_on_helful")

# Extracting length of reviewtext as "reviewtext_length" and storing as "kindle_text_length_df".

kindle_text_length_df <- SparkR::sql("SELECT *, length(reviewText) as reviewtext_length from kindle_filtered_on_helful")

head(kindle_text_length_df)

# Converting unixReviewTime from unixtime format to date-time format.

createOrReplaceTempView(kindle_text_length_df, "kindle_text_length_df")

kindle_unix_to_date <- SparkR::sql("SELECT *, from_unixtime(unixReviewTime) as timestamp from kindle_text_length_df")
head(kindle_unix_to_date)

# Storing "kindle_unix_to_date" as "kindle_store_final".

kindle_store_final <- kindle_unix_to_date

#-------------------------------------------------------------------------------------------------------------------------------------------------------------

## Collecting SparkR dataframes (movies_and_tv_final, cds_and_vinyl_final and kindle_store_final)
# as (movies_local_df,cds_local_df and kindle_local_df) respectively for further analysis.

movies_local_df <- collect(select(movies_and_tv_final, "reviewerID", "asin", "helpfulness", "overall", "reviewtext_length", "timestamp"))

cds_local_df <- collect(select(cds_and_vinyl_final, "reviewerID", "asin", "helpfulness", "overall", "reviewtext_length", "timestamp"))

kindle_local_df <- collect(select(kindle_store_final, "reviewerID","asin", "helpfulness", "overall","reviewtext_length", "timestamp"))

# Checking structure of these datframes.

str(movies_local_df)
str(cds_local_df)
str(kindle_local_df)

#--------------------------------------------------------------------------------------------------------------------------------------------------------------

## 1. Identifying product category that has larger market size.

# Note: All the following analysis will be done using local R dataframes not SparkR dataframes.

# Determining market size using "Number of reviewers" as proxy metric.

# Determining "Number of reviewers" from "movies_local_df" and storing it as "no_of_reviewers_movies". 

no_of_reviewers_movies <- length(unique(movies_local_df$reviewerID))
no_of_reviewers_movies

# Determining "Number of reviewers" from "cds_local_df" and storing it as "no_of_reviewers_cds". 

no_of_reviewers_cds <- length(unique(cds_local_df$reviewerID))
no_of_reviewers_cds

# Determining "Number of reviewers" from "kindle_local_df" and storing it as "no_of_reviewers_kindle". 

no_of_reviewers_kindle <- length(unique(kindle_local_df$reviewerID))
no_of_reviewers_kindle

# Number of reviewers for movies_and_tv is 30982 which is high followed by cds_and_vinyl (no. of reviewers = 24465) and kindle_store (no. of reviewers = 9128).
# Hence product "movies_and_tv" has a larger market size.

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## 2. Identifying product category that is likely to be purchased heavily.

# Identifying heavily purchased product category using number of product reviews as proxy metric.

# Determining "Number of reviews" from "movies_local_df" and storing it as "no_of_reviews_movies". 

no_of_reviews_movies <- length(unique(movies_local_df$asin))
no_of_reviews_movies

# Determining "Number of reviews" from "cds_local_df" and storing it as "no_of_reviews_cds". 

no_of_reviews_cds <- length(unique(cds_local_df$asin))
no_of_reviews_cds

# Determining "Number of reviews" from "kindle_local_df" and storing it as "no_of_reviews_kindle". 

no_of_reviews_kindle <- length(unique(kindle_local_df$asin))
no_of_reviews_kindle

# Total number of reviews for cds and vinyl (i.e. 39929) is high when compared to number of reviews for movies and tv(i.e. 35963) and number of reviews for kindle(i.e. 8173).


## Calculating number of units sold in each product category by taking ratio of number of reviews of two categories.

# Creating a matrix called "reviews_matrix" and storing number of reviews of all categories. 

reviews_matrix <- matrix(c(35963, 39929, 8173), nrow = 3, ncol = 3, byrow = FALSE)

# Note: In above matrix, 35963 corresponds to no_of_reviews for "movies_and_tv".
# 39929 corresponds to no_of_reviews for "cds_and_vinyl".
# 8173 corresponds to no_of_reviews for "kindle_store".

# Similarly creating a vector containing number of reviews and storing it as "reviews_vector".

reviews_vector <- c(35963, 39929, 8173)

# Dividing "reviews_matrix" by "reviews_vector" to get ratio of number of reviews.

apply(reviews_matrix, 1, function(x) x/reviews_vector)

# Number of units of cds and vinyl sold is 4.88 times more than number of units of kindle books sold.
# This is the highest ratio amongst all ratios.
# The number of reviews is highest for cds_and_vinyl and they are sold 4.88 times more when compared to other categories. 
# Hence "cds_and_vinyl" is the product category that is heavily purchased.

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## 3. Identifying product category that is likely to make customers happy after the purchase.

# Calculating mean_rating for all categories to determine customer satisfaction.

# Calculating mean_rating for "movies_and_tv" and storing as "mean_rating_movies".

mean_rating_movies <- mean(movies_local_df$overall)
mean_rating_movies

# Calculating mean_rating for "cds_and_vinyl" and storing as "mean_rating_cds".

mean_rating_cds <- mean(cds_local_df$overall)
mean_rating_cds

# Calculating mean_rating for "kindle_store" and storing as "mean_rating_kindle".

mean_rating_kindle <- mean(kindle_local_df$overall)
mean_rating_kindle

# Mean rating for "cds_and_vinyl" is high when compared to other categories.


## Analysing distribution of "overall" rating across three categories.

# Loading the following library.

library(dplyr)

# Calculating proportion of ratings in "movies and tv" category and storing it as "movie_ratings".

movie_ratings <- movies_local_df %>%
  
  group_by(overall) %>%
  
  summarise(rating_count = n()) %>%
  
  mutate(total_ratings = sum(rating_count), rating_proportion = (rating_count/total_ratings))


# Calculating proportion of ratings in "cds and vinyl" category and storing it as "cd_ratings".

cd_ratings <- cds_local_df %>%
  
  group_by(overall) %>%
  
  summarise(rating_count = n()) %>%
  
  mutate(total_ratings = sum(rating_count), rating_proportion = (rating_count/total_ratings))


# Calculating proportion of ratings in "kindle_store" category and storing it as "kindle_ratings".

kindle_ratings <- kindle_local_df %>%
  
  group_by(overall) %>%
  
  summarise(rating_count = n()) %>%
  
  mutate(total_ratings = sum(rating_count), rating_proportion = (rating_count/total_ratings))


# Plotting distribution of ratings for "movies_and_tv" category and storing it as "movie_rating".

# Loading the following library.

library(ggplot2)

movie_rating <- ggplot(movie_ratings, aes(x = factor(overall), y = rating_proportion, fill = factor(overall))) + scale_y_continuous(labels = scales::percent) + labs(title = "Ratings for movies and tv", x = "overall", y = "Percentage of ratings") 
movie_rating +  geom_bar(position = "stack", stat = "identity") + geom_text(aes(label = sprintf("%0.2f", round((rating_proportion*100), digits=2))), vjust = 1.5, position = "stack")

# Plotting distribution of ratings for "cds_and_vinyl" category and storing it as "cd_rating".

cd_rating <- ggplot(cd_ratings, aes(x = factor(overall), y = rating_proportion, fill = factor(overall))) + scale_y_continuous(labels = scales::percent) + labs(title = "Ratings for cds and vinyl", x = "overall", y = "Percentage of ratings") 
cd_rating +  geom_bar(position = "stack", stat = "identity") + geom_text(aes(label = sprintf("%0.2f", round((rating_proportion*100), digits=2))), vjust = 1.5, position = "stack")

# Plotting distribution of ratings for "kindle_store" category and storing it as "kindle_rating".

kindle_rating <- ggplot(kindle_ratings, aes(x = factor(overall), y = rating_proportion, fill = factor(overall))) + scale_y_continuous(labels = scales::percent) + labs(title = "Ratings for kindle store", x = "overall", y = "Percentage of ratings") 
kindle_rating +  geom_bar(position = "stack", stat = "identity") + geom_text(aes(label = sprintf("%0.2f", round((rating_proportion*100), digits=2))), vjust = 1.5, position = "stack")

# cds_and_vinyl has received 62.48% of rating "5".
# kindle_store has received 56.27% of rating "5".
# movies_and_tv has received 49.75% of rating "5".
# Hence category "cds_and_vinyl" has received highest percentage of rating "5" indicating that the customer satisfaction for this category is high.

#---------------------------------------------------------------------------------------------------------------------------------------------------------------

## Comparing the distribution of ratings across years for all categories.

# Converting "timestamp" from "movies_local_df" to date format.

movies_local_df$timestamp <- as.Date(movies_local_df$timestamp)

# Extracting year from timestamp and storing it as "Year".

movies_local_df$Year <- format(movies_local_df$timestamp, '%Y')

# Converting "timestamp" from "cds_local_df" to date format.

cds_local_df$timestamp <- as.Date(cds_local_df$timestamp)

# Extracting year from timestamp and storing it as "Year".

cds_local_df$Year <- format(cds_local_df$timestamp, '%Y')

# Converting "timestamp" from "kindle_local_df" to date format.

kindle_local_df$timestamp <- as.Date(kindle_local_df$timestamp)

# Extracting year from timestamp and storing it as "Year".

kindle_local_df$Year <- format(kindle_local_df$timestamp, '%Y')


# Grouping data by Year and overall and counting the number of ratings and storing it in df "movies_year_wise_rating".

movies_year_wise_rating <- movies_local_df %>%
  
  group_by(Year, overall) %>% 
  
  summarise(no_of_ratings = n()) 

# Grouping data by Year and overall and counting the number of ratings and storing it in df "cds_year_wise_rating".

cds_year_wise_rating <- cds_local_df %>%
  
  group_by(Year, overall) %>% 
  
  summarise(no_of_ratings = n())

# Grouping data by Year and overall and counting the number of ratings and storing it in df "kindle_year_wise_rating".

kindle_year_wise_rating <- kindle_local_df %>%
  
  group_by(Year, overall) %>% 
  
  summarise(no_of_ratings = n())

# Plotting distribution of ratings across years for all categories.

# Plotting distribution of ratings for "movies_and_tv" and storing it as "year_wise_ratings_movies".

year_wise_ratings_movies <- ggplot(movies_year_wise_rating, aes(x = factor(Year), y = no_of_ratings, fill = factor(overall))) + geom_bar(stat = "identity", position = "fill") + 
  labs(title = "Rating distribution over years for movies and tv", x = "Year", y = "Proportion of ratings") 

# Plotting distribution of ratings for "cds_and_vinyl" and storing it as "year_wise_ratings_cds".

year_wise_ratings_cds <- ggplot(cds_year_wise_rating, aes(x = factor(Year), y = no_of_ratings, fill = factor(overall))) + geom_bar(stat = "identity", position = "fill") + 
  labs(title = "Rating distribution over years for cds and movies", x = "Year", y = "Proportion of ratings") 

# Plotting distribution of ratings for "kindle_store" and storing it as "year_wise_ratings_kindle".

year_wise_ratings_kindle <- ggplot(kindle_year_wise_rating, aes(x = factor(Year), y = no_of_ratings, fill = factor(overall))) + geom_bar(stat = "identity", position = "fill") + 
  labs(title = "Rating distribution over years for kindle store", x = "Year", y = "Proportion of ratings") 

# Loading following library.

library(gridExtra)

# Arranging above mentioned three plots in a single view.

grid.arrange(year_wise_ratings_movies, year_wise_ratings_cds, year_wise_ratings_kindle)

# Proportion of rating "5" has decreased over years for "movies_and_tv".
# "cds_and_vinyl" has maintained high proportion of rating "5" and over years this proportion has remained constant.
# "kindle_store" has mixed pattern of raing "5".
# Hence over years, customers have given high rating consistently to "cds_and_vinyl".

#----------------------------------------------------------------------------------------------------------------------------------------------------

# Determining correlation between "helfulness", "overall" and "reviewtext_length" for all three product categories.

# Creating a dataframe named "columns" containing only desired columns.

columns <- c("helpfulness", "overall", "reviewtext_length")

# Subsetting movies_local_df to include only desired columns and storing it as "movies_correlation".

movies_correlation <- movies_local_df[names(movies_local_df) %in% columns]

# Subsetting cds_local_df to include only desired columns and storing it as "cds_correlation".

cds_correlation <- cds_local_df[names(cds_local_df) %in% columns]

# Subsetting kindle_local_df to include only desired columns and storing it as "kindle_correlation".

kindle_correlation <- kindle_local_df[names(kindle_local_df) %in% columns]

# Installing "GGally" package to create correlation matrix.

install.packages("GGally")

# Loading "GGally" library.

library(GGally)

# Creating correlation matrix for "movies_and_tv" category.

ggcorr(movies_correlation, method = c("pairwise", "pearson"), label = TRUE, hjust = 1) + labs(title = "Correlation matrix for movies and tv")

# Creating correlation matrix for "cds_and_vinyl" category.

ggcorr(cds_correlation, method = c("pairwise", "pearson"), label = TRUE, hjust = 1) + labs(title = "Correlation matrix for cds and vinyl")

# # Creating correlation matrix for "kindle_store" category.

ggcorr(kindle_correlation, method = c("pairwise", "pearson"), label = TRUE, hjust = 1) + labs(title = "Correlation matrix for kindle store")

# Correlation matrix of "movies_and_tv" shows a positive correlation of 0.1 between attributes "overall", "helpfulness" and "reviewtext_length".
# A positive correlation is seen between these attributes for "cds_and_vinyl" also.
# Hence in case of "movies_and_tv" and "cds_and_vinyl", a longer review is expected to have higher rating.
# But Correlation matrix of "kindle_store" shows a negative correaltion of -0.1 between "overall" and "reviewtext_length".
# Hence in case of "kindle_store", shorter reviews have higher rating.

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Analysing distribution of ratings across different text lengths.

# Plotting histogram to visualize distribution of review text length for "movies_and_tv".

ggplot(movies_local_df, aes(x = reviewtext_length)) + geom_histogram(breaks=seq(0, 30000, by = 500))

# Plotting histogram to visualize distribution of review text length for "cds_and_vinyl".

ggplot(cds_local_df, aes(x = reviewtext_length)) + geom_histogram(breaks=seq(0, 30000, by = 500))

# Plotting histogram to visualize distribution of review text length for "kindle_store".

ggplot(kindle_local_df, aes(x = reviewtext_length)) + geom_histogram(breaks=seq(0, 30000, by = 500))

# From above graphs, it is clear that many customers write reviews that have 0 to 500 words and 500 to 1000 words.


# creating different bins for reviewtext_length.

movies_local_df$textlength_bins <- cut(movies_local_df$reviewtext_length, breaks = c(0,10000,20000,30000,40000), labels = c("0-10000","10000-20000","20000-30000","30000-40000"), include.lowest = TRUE)

cds_local_df$textlength_bins <- cut(cds_local_df$reviewtext_length, breaks = c(0,10000,20000,30000,40000), labels = c("0-10000","10000-20000","20000-30000","30000-40000"), include.lowest = TRUE)

kindle_local_df$textlength_bins <- cut(kindle_local_df$reviewtext_length, breaks = c(0,5000,10000,15000,20000), labels = c("0-5000","5000-10000","10000-15000","15000-20000"), include.lowest = TRUE)

# Grouping by textlength_bins and overall and calculating rating proportion for "movies_and_tv".

length_wise_rating_movies <- movies_local_df %>%
  group_by(textlength_bins, overall) %>%
  summarise(no_of_rating = n()) %>%
  mutate(total_ratings = sum(no_of_rating), rating_proportion = (no_of_rating/total_ratings))

# Grouping by textlength_bins and overall and calculating rating proportion for "cds_and_vinyl".

length_wise_rating_cds <- cds_local_df %>%
  group_by(textlength_bins, overall) %>%
  summarise(no_of_rating = n()) %>%
  mutate(total_ratings = sum(no_of_rating), rating_proportion = (no_of_rating/total_ratings))

# Grouping by textlength_bins and overall and calculating rating proportion for "kindle_store".

length_wise_rating_kindle <- kindle_local_df %>%
  group_by(textlength_bins, overall) %>%
  summarise(no_of_rating = n()) %>%
  mutate(total_ratings = sum(no_of_rating), rating_proportion = (no_of_rating/total_ratings))


# Plotting distribution of ratings across textlength_bins for "movies_and_tv" and storing it as "movies_ratings_bin_wise".

movies_ratings_bin_wise <- ggplot(length_wise_rating_movies, aes(x = factor(textlength_bins), y = rating_proportion, fill = factor(overall))) + scale_y_continuous(labels = scales::percent) + labs(title = "Ratings for movies and tv", x = "Textlength_bins", y = "Percentage of ratings") +  
  geom_bar(position = "stack", stat = "identity") + geom_text(aes(label = sprintf("%0.2f", round((rating_proportion*100), digits=2))), vjust = 1.5, position = "stack") 

# Plotting distribution of ratings across textlength_bins for "cds_and_vinyl" and storing it as "cds_ratings_bin_wise".

cds_ratings_bin_wise <- ggplot(length_wise_rating_cds, aes(x = factor(textlength_bins), y = rating_proportion, fill = factor(overall))) + scale_y_continuous(labels = scales::percent) + labs(title = "Ratings for cds and vinyl", x = "Textlength_bins", y = "Percentage of ratings") +  
  geom_bar(position = "stack", stat = "identity") + geom_text(aes(label = sprintf("%0.2f", round((rating_proportion*100), digits=2))), vjust = 1.5, position = "stack") 

# Plotting distribution of ratings across textlength_bins for "kindle_store" and storing it as "kindle_ratings_bin_wise".

kindle_ratings_bin_wise <- ggplot(length_wise_rating_kindle, aes(x = factor(textlength_bins), y = rating_proportion, fill = factor(overall))) + scale_y_continuous(labels = scales::percent) + labs(title = "Ratings for kindle store", x = "Textlength_bins", y = "Percentage of ratings") +  
  geom_bar(position = "stack", stat = "identity") + geom_text(aes(label = sprintf("%0.2f", round((rating_proportion*100), digits=2))), vjust = 1.5, position = "stack") 

# Arranging above plots into single view.

grid.arrange(movies_ratings_bin_wise, cds_ratings_bin_wise, kindle_ratings_bin_wise)

# Percentage of ratings as "5" is much higher for "cds_and_vinyl" across all text lengths when compared to other categories.

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Conclusions:

# 1. Product category that has larger market size is "movies_and_tv".
# This is because the number of reviewers for "movies_and_tv" is 30982 which is higher when compared to cds_and_vinyl(no of reviewers = 24465) and kindle_store(no of reviewers = 9128).

# 2. Product category that is heavily purchased is "cds_and_vinyl".
# This is because: 
# a. Number of reviews for "cds_and_vinyl" is 39929 which is higher compared to other categories.
# b. The number of units of products sold for "cds_and_vinyl" is 4.88 times the number of units of products of kindle sold.

# 3. Product category that is likely to make customers happy is "cds_and_vinyl".
# This is because:
# a. The mean rating for "cds_and_vinyl" is 4.26 which is higher than movies_and_tv(mean rating = 3.89) and kindle store(mean rating = 4.00).
# b. "cds_and_vinyl" has received highest percentage (62.48%) of overall rating "5".
# c. When compared over years, "cds_and_vinyl" has consistently received high proportion of rating "5".
# d. Across all reviewtext lengths, percentage of raings as "5" is much higher for "cds_and_vinyl".

# Although "movies_and_tv" has larger market size, it has low proportion of units of products sold and it has not attained highest ratings consistently.
# Therefore the product category that one must invest in is "cds_and_vinyl" as it has a good market size of 24465 customers, it has also been purchased more and also has highest customer satisfaction.

#---------------------------------------END-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

