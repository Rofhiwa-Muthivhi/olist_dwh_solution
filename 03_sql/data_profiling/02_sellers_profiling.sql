USE [olist_stg];
GO

-- checking the total number of seller records ingested into bronze

SELECT
    COUNT(*) AS total_sellers
FROM [olist_stg].[bronze].[sellers];


-- checking the number of columns in the sellers table

SELECT COUNT(*) AS total_columns
FROM [olist_stg].[INFORMATION_SCHEMA].[COLUMNS]
WHERE TABLE_SCHEMA = 'bronze'
AND TABLE_NAME = 'sellers';


-- verifying that each seller record has a unique seller id and identifying any repeated ids

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT seller_id) AS unique_seller_ids,
    COUNT(*) - COUNT(DISTINCT seller_id) AS duplicate_seller_ids
FROM [olist_stg].[bronze].[sellers];


-- checking for missing values in the seller information

SELECT
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
    SUM(CASE WHEN seller_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_zip_prefix,
    SUM(CASE WHEN seller_city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN seller_state IS NULL THEN 1 ELSE 0 END) AS null_state
FROM [olist_stg].[bronze].[sellers];


-- analysing how sellers are distributed across different cities

SELECT
    seller_city,
    COUNT(*) AS total_sellers
FROM [olist_stg].[bronze].[sellers]
GROUP BY seller_city
ORDER BY total_sellers DESC;


-- identifying the different states in which sellers operate

SELECT
    seller_state,
    COUNT(*) AS total_sellers
FROM [olist_stg].[bronze].[sellers]
GROUP BY seller_state
ORDER BY seller_state;


-- checking whether seller zip prefixes consistently contain five characters

SELECT
    LEN(CAST(seller_zip_code_prefix AS VARCHAR(20))) AS zip_prefix_length,
    COUNT(*) AS total_records
FROM [olist_stg].[bronze].[sellers]
GROUP BY LEN(CAST(seller_zip_code_prefix AS VARCHAR(20)))
ORDER BY zip_prefix_length;


-- analysing the number of sellers operating in each state to understand their geographical distribution

SELECT
    seller_state,
    COUNT(*) AS total_sellers
FROM [olist_stg].[bronze].[sellers]
GROUP BY seller_state
ORDER BY total_sellers DESC;


-- identifying seller city names with inconsistent spacing that may require standardisation

SELECT
    seller_city,
    COUNT(*) AS total_records
FROM [olist_stg].[bronze].[sellers]
WHERE
    seller_city <> LTRIM(RTRIM(seller_city))
    OR seller_city LIKE '%  %'
GROUP BY seller_city
ORDER BY total_records DESC;