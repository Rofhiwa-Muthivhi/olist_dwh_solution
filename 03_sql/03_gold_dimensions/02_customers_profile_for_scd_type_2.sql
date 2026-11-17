--================================================================================
-- i am checking the first 10 records in the silver customers table to understand
-- the customer information available for building the gold customer dimension.
--================================================================================

SELECT TOP (10) 
       [customer_id]
      ,[customer_unique_id]
      ,[customer_zip_code_prefix]
      ,[customer_city]
      ,[customer_state]
      ,[dwh_load_ts]
FROM [olist_dwh].[silver].[customers];


--================================================================================
-- i am profiling the customers table to identify customers who appear more than
-- once and check whether their zip code, city or state information is different.
-- this will help me understand whether repeated customer records contain
-- different location information before implementing scd type 2.
--================================================================================

SELECT
    customer_unique_id,
    COUNT(*) AS record_count,
    COUNT(DISTINCT customer_zip_code_prefix) AS unique_zip_codes,
    COUNT(DISTINCT customer_city) AS unique_cities,
    COUNT(DISTINCT customer_state) AS unique_states

FROM [olist_dwh].[silver].[customers]

GROUP BY customer_unique_id

HAVING COUNT(*) > 1

ORDER BY record_count DESC;


--================================================================================
-- i am investigating customers who have more than one zip code prefix to
-- understand whether their location information differs across repeated records.
-- this will help me identify possible changes in customer information and
-- establish the need for historical tracking using scd type 2.
--================================================================================

SELECT
    customer_unique_id,
    customer_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state

FROM [olist_dwh].[silver].[customers]

WHERE customer_unique_id = 
(
    SELECT TOP 1 customer_unique_id
    FROM [olist_dwh].[silver].[customers]
    GROUP BY customer_unique_id
    HAVING COUNT(DISTINCT customer_zip_code_prefix) > 1
    ORDER BY COUNT(DISTINCT customer_zip_code_prefix) DESC
)

ORDER BY customer_zip_code_prefix;


--================================================================================
-- i am joining the silver customers and orders tables using customer_id to
-- investigate when the customer records were associated with different locations.
-- the order purchase date will help me establish the chronological order of
-- these records before implementing scd type 2.
--================================================================================

SELECT
    c.customer_unique_id,
    c.customer_id,
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state,
    o.order_id,
    o.order_purchase_timestamp

FROM [olist_dwh].[silver].[customers] AS c

INNER JOIN [olist_dwh].[silver].[orders] AS o
    ON c.customer_id = o.customer_id

WHERE c.customer_unique_id =
(
    SELECT TOP 1 customer_unique_id
    FROM [olist_dwh].[silver].[customers]
    GROUP BY customer_unique_id
    HAVING COUNT(DISTINCT customer_zip_code_prefix) > 1
    ORDER BY COUNT(DISTINCT customer_zip_code_prefix) DESC
)

ORDER BY o.order_purchase_timestamp ASC;


