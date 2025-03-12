# Import
library(dplyr)
library(RSQLite)

data1 <- read.csv("/Users/illurisaisandeep/Desktop/Academics/NUS Journey/NUS Maritime Projects/Market Analysis and Customer Segmentation/E-commerece sales data 2024.csv")
data2 <- read.csv("/Users/illurisaisandeep/Desktop/Academics/NUS Journey/NUS Maritime Projects/Market Analysis and Customer Segmentation/customer_details.csv")
data3 <- read.csv("/Users/illurisaisandeep/Desktop/Academics/NUS Journey/NUS Maritime Projects/Market Analysis and Customer Segmentation/product_details.csv")

conn <- dbConnect(RSQLite::SQLite(), ":memory:")
dbWriteTable(conn, "data1", data1)
dbWriteTable(conn, "data2", data2)
dbWriteTable(conn, "data3", data3)

query <- "
SELECT 
    d1.*, 
    d2.*, 
    d3.*
FROM 
    data1 d1
JOIN 
    data3 d3 ON d1.`product id` = d3.`Uniqe Id`
JOIN 
    data2 d2 ON d1.`user id` = d2.`Customer ID`
"

merged_data <- dbGetQuery(conn, query)

dbDisconnect(conn)



# Preprocessing
merged_data <- merged_data[, colSums(is.na(merged_data)) < nrow(merged_data)]

merged_data <- na.omit(merged_data)

merged_data <- merged_data[!is.na(merged_data$`Customer ID`) & !is.na(merged_data$`product id`), ]



# Market Analysis
purchase_data <- merged_data %>% filter(`Interaction type` == 'purchase')

overall_stats <- data.frame(
  "Business Question" = c(
    "1. What is the total revenue?", 
    "2. What is the average purchase value?", 
    "3. Which item is the most purchased?", 
    "4. What is the most common location?", 
    "5. What is the average customer age?", 
    "6. What is the gender proportion of male customers?", 
    "7. What is the gender proportion of female customers?", 
    "8. What is the average review rating?", 
    "9. What is the most preferred payment method?", 
    "10. What proportion of purchases had a discount applied?", 
    "11. What proportion of purchases used a promo code?", 
    "12. What proportion of customers are subscribed?", 
    "13. What is the most common shipping type?", 
    "14. What is the average selling price?", 
    "15. Which item is the most common item purchased?", 
    "16. What is the average frequency of purchases?", 
    "17. What is the most common shipping weight?", 
    "18. What proportion of sellers are Amazon sellers?"
  ),
  "Values" = c(
    sum(purchase_data$`Purchase Amount (USD)`),
    mean(purchase_data$`Purchase Amount (USD)`),
    names(sort(table(purchase_data$`Item Purchased`), decreasing = TRUE))[1],
    names(sort(table(purchase_data$Location), decreasing = TRUE))[1],
    mean(purchase_data$Age),
    sum(purchase_data$Gender == "Male") / nrow(purchase_data),
    sum(purchase_data$Gender == "Female") / nrow(purchase_data),
    mean(purchase_data$`Review Rating`),
    names(sort(table(purchase_data$`Payment Method`), decreasing = TRUE))[1],
    mean(purchase_data$`Discount Applied` == "Yes"),
    mean(purchase_data$`Promo Code Used` == "Yes"),
    mean(purchase_data$`Subscription Status` == "Yes"),
    names(sort(table(purchase_data$`Shipping Type`), decreasing = TRUE))[1],
    mean(purchase_data$`Selling Price`),
    names(sort(table(purchase_data$`Item Purchased`), decreasing = TRUE))[1],
    mean(purchase_data$`Frequency of Purchases`),
    mean(purchase_data$`Shipping Weight`),
    mean(purchase_data$`Is Amazon Seller` == "Y")
  )
)

print(overall_stats)



# Customer Segmentation
clustering_data <- purchase_data %>%
  select(Age, `Purchase Amount (USD)`, `Previous Purchases`, `Frequency of Purchases_encoded`, 
         `Subscription Status_encoded`, `Discount Applied_encoded`, `Promo Code Used_encoded`,
         `Shipping Type_encoded`, `Payment Method_encoded`) %>%
  na.omit()

scaled_data <- scale(clustering_data)

set.seed(42)
wcss <- numeric(9)
for (k in 2:10) {
  kmeans_result <- kmeans(scaled_data, centers = k, nstart = 10)
  wcss[k - 1] <- kmeans_result$tot.withinss
}

plot(2:10, wcss, type = "b", main = "Elbow Method", xlab = "Number of Clusters", ylab = "WCSS")

optimal_k <- 3
kmeans_result <- kmeans(scaled_data, centers = optimal_k, nstart = 10)

clustering_data$Cluster <- kmeans_result$cluster

library(cluster)
sil_score <- silhouette(kmeans_result$cluster, dist(scaled_data))
sil_score_avg <- mean(sil_score[, 3])
print(paste("Silhouette Score:", sil_score_avg))

pca_result <- prcomp(scaled_data)
pca_data <- as.data.frame(pca_result$x)
pca_data$Cluster <- as.factor(kmeans_result$cluster)

library(ggplot2)
ggplot(pca_data, aes(x = PC1, y = PC2, color = Cluster)) +
  geom_point() +
  ggtitle("Customer Segmentation Clusters (PCA Visualization)")



# Recommendation System
library(recommenderlab)
library(Matrix)

recommend_data <- merged_data %>%
  select(`Customer ID`, `Item Purchased`, `Purchase Amount (USD)`, `Review Rating`)

customer_item_matrix <- recommend_data %>%
  spread(`Item Purchased`, `Purchase Amount (USD)`, fill = 0)

sparse_matrix <- as(customer_item_matrix[, -1], "CsparseMatrix")

rec_model <- Recommender(sparse_matrix, method = "UBCF", param = list(k = 5))

customer_id <- 669
user_index <- which(rownames(sparse_matrix) == as.character(customer_id))
recommended_items <- predict(rec_model, sparse_matrix[user_index, , drop = FALSE], n = 5)

recommended_items