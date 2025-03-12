CREATE DATABASE ecommerce_data;
USE ecommerce_data;

CREATE TABLE data1 (
    `user id` INT,
    `product id` VARCHAR(255),
    `Interaction type` VARCHAR(255),
    `Time stamp` DATETIME,
    `Unnamed: 4` VARCHAR(255)
);

CREATE TABLE data2 (
    `Customer ID` INT,
    `Age` INT,
    `Gender` VARCHAR(50),
    `Item Purchased` VARCHAR(255),
    `Category` VARCHAR(255),
    `Purchase Amount (USD)` DECIMAL(10, 2),
    `Location` VARCHAR(255),
    `Size` VARCHAR(50),
    `Color` VARCHAR(50),
    `Season` VARCHAR(50),
    `Review Rating` DECIMAL(2, 1),
    `Subscription Status` VARCHAR(50),
    `Shipping Type` VARCHAR(255),
    `Discount Applied` VARCHAR(50),
    `Promo Code Used` VARCHAR(50),
    `Previous Purchases` INT,
    `Payment Method` VARCHAR(50),
    `Frequency of Purchases` VARCHAR(50)
);

CREATE TABLE data3 (
    `Uniqe Id` VARCHAR(255),
    `Product Name` VARCHAR(255),
    `Brand Name` VARCHAR(255),
    `Asin` VARCHAR(255),
    `Category` VARCHAR(255),
    `Upc Ean Code` VARCHAR(255),
    `List Price` DECIMAL(10, 2),
    `Selling Price` DECIMAL(10, 2),
    `Quantity` INT,
    `Model Number` VARCHAR(255),
    `Product Url` VARCHAR(255),
    `Stock` INT,
    `Product Details` TEXT,
    `Dimensions` VARCHAR(255),
    `Color` VARCHAR(50),
    `Ingredients` TEXT,
    `Direction To Use` TEXT,
    `Is Amazon Seller` VARCHAR(50),
    `Size Quantity Variant` VARCHAR(255),
    `Product Description` TEXT
);

LOAD DATA INFILE 'E-commerece_sales_data_2024.csv'
INTO TABLE data1
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'customer_details.csv'
INTO TABLE data2
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'product_details.csv'
INTO TABLE data3
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT 
    d1.*, 
    d2.*, 
    d3.*
FROM 
    data1 d1
JOIN 
    data3 d3 ON d1.`product id` = d3.`Uniqe Id`
JOIN 
    data2 d2 ON d1.`user id` = d2.`Customer ID`;

