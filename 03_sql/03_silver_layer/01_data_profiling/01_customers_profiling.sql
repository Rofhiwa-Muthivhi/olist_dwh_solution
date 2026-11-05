USE [olist_stg];
GO

-- checking how many customer records we have in the customers table

SELECT
    COUNT(*) AS total_customers
FROM [olist_stg].[bronze].[customers];


-- verifying that each customer record has a unique customer id and identifying any repeated ids

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,
    COUNT(*) - COUNT(DISTINCT customer_id) AS duplicate_customer_ids
FROM [olist_stg].[bronze].[customers];


-- checking for missing values in the customer information

SELECT
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) AS null_customer_unique_id,
    SUM(CASE WHEN customer_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_zip_prefix,
    SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS null_state
FROM [olist_stg].[bronze].[customers];


-- identifying customers who appear under multiple customer records

SELECT
    customer_unique_id,
    COUNT(*) AS total_records
FROM [olist_stg].[bronze].[customers]
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY total_records DESC;


-- checking how customer city names are currently represented

SELECT
    customer_city,
    COUNT(*) AS total_customers
FROM [olist_stg].[bronze].[customers]
GROUP BY customer_city
ORDER BY total_customers DESC;


-- checking the different state values and how they are represented

SELECT
    customer_state,
    COUNT(*) AS total_customers
FROM [olist_stg].[bronze].[customers]
GROUP BY customer_state
ORDER BY customer_state;


-- checking whether customer zip prefixes consistently contain five characters

SELECT
    LEN(customer_zip_code_prefix) AS zip_prefix_length,
    COUNT(*) AS total_records
FROM [olist_stg].[bronze].[customers]
GROUP BY LEN(customer_zip_code_prefix)
ORDER BY zip_prefix_length;


-- analysing the distribution of customers across different states to understand their geographical representation

SELECT
    customer_state,
    COUNT(*) AS total_customers
FROM [olist_stg].[bronze].[customers]
GROUP BY customer_state
ORDER BY total_customers DESC;