
USE [olist_stg];
GO


-- check the latest ingestion batch recorded in the etl load log
-- return the batch details, including the source files, number of rows loaded, load status, and timestamp
-- this helps confirm that the most recent bronze ingestion batch was recorded successfully

SELECT *
FROM [olist_stg].[etl].[load_log]
WHERE batch_id = (SELECT MAX(batch_id) FROM [olist_stg].[etl].[load_log])
ORDER BY load_log_id;




-- check bronze table record counts against the etl load log
-- compare the actual number of records loaded into each bronze table against the number of records recorded in the etl load log
-- this helps verify that all nine source datasets were ingested successfully and that the record counts match

SELECT 'customers' AS dataset,
       (SELECT COUNT(*) FROM [olist_stg].[bronze].[customers]) AS bronze_records,
       (SELECT rows_loaded FROM [olist_stg].[etl].[load_log]
        WHERE source_file = 'olist_customers_dataset.csv'
        AND batch_id = (SELECT MAX(batch_id) FROM [olist_stg].[etl].[load_log])) AS logged_records

UNION ALL

SELECT 'geolocation',
       (SELECT COUNT(*) FROM [olist_stg].[bronze].[geolocation]),
       (SELECT rows_loaded FROM [olist_stg].[etl].[load_log]
        WHERE source_file = 'olist_geolocation_dataset.csv'
        AND batch_id = (SELECT MAX(batch_id) FROM [olist_stg].[etl].[load_log]))

UNION ALL

SELECT 'order_items',
       (SELECT COUNT(*) FROM [olist_stg].[bronze].[order_items]),
       (SELECT rows_loaded FROM [olist_stg].[etl].[load_log]
        WHERE source_file = 'olist_order_items_dataset.csv'
        AND batch_id = (SELECT MAX(batch_id) FROM [olist_stg].[etl].[load_log]))

UNION ALL

SELECT 'order_payments',
       (SELECT COUNT(*) FROM [olist_stg].[bronze].[order_payments]),
       (SELECT rows_loaded FROM [olist_stg].[etl].[load_log]
        WHERE source_file = 'olist_order_payments_dataset.csv'
        AND batch_id = (SELECT MAX(batch_id) FROM [olist_stg].[etl].[load_log]))

UNION ALL

SELECT 'order_reviews',
       (SELECT COUNT(*) FROM [olist_stg].[bronze].[order_reviews]),
       (SELECT rows_loaded FROM [olist_stg].[etl].[load_log]
        WHERE source_file = 'olist_order_reviews_dataset.csv'
        AND batch_id = (SELECT MAX(batch_id) FROM [olist_stg].[etl].[load_log]))

UNION ALL

SELECT 'orders',
       (SELECT COUNT(*) FROM [olist_stg].[bronze].[orders]),
       (SELECT rows_loaded FROM [olist_stg].[etl].[load_log]
        WHERE source_file = 'olist_orders_dataset.csv'
        AND batch_id = (SELECT MAX(batch_id) FROM [olist_stg].[etl].[load_log]))

UNION ALL

SELECT 'products',
       (SELECT COUNT(*) FROM [olist_stg].[bronze].[products]),
       (SELECT rows_loaded FROM [olist_stg].[etl].[load_log]
        WHERE source_file = 'olist_products_dataset.csv'
        AND batch_id = (SELECT MAX(batch_id) FROM [olist_stg].[etl].[load_log]))

UNION ALL

SELECT 'sellers',
       (SELECT COUNT(*) FROM [olist_stg].[bronze].[sellers]),
       (SELECT rows_loaded FROM [olist_stg].[etl].[load_log]
        WHERE source_file = 'olist_sellers_dataset.csv'
        AND batch_id = (SELECT MAX(batch_id) FROM [olist_stg].[etl].[load_log]))

UNION ALL

SELECT 'product_category_name_translation',
       (SELECT COUNT(*) FROM [olist_stg].[bronze].[product_category_name_translation]),
       (SELECT rows_loaded FROM [olist_stg].[etl].[load_log]
        WHERE source_file = 'product_category_name_translation.csv'
        AND batch_id = (SELECT MAX(batch_id) FROM [olist_stg].[etl].[load_log]));




-- check whether the metadata columns contain null values across the bronze tables
-- count the total records in each table and identify missing values in the dwh_load_ts, dwh_source_file, and dwh_batch_id columns
-- this helps verify that the metadata was populated correctly during the bronze ingestion process

SELECT 'customers' AS dataset,
       COUNT(*) AS total_records,
       SUM(CASE WHEN dwh_load_ts IS NULL THEN 1 ELSE 0 END) AS missing_load_ts,
       SUM(CASE WHEN dwh_source_file IS NULL THEN 1 ELSE 0 END) AS missing_source_file,
       SUM(CASE WHEN dwh_batch_id IS NULL THEN 1 ELSE 0 END) AS missing_batch_id
FROM [olist_stg].[bronze].[customers]

UNION ALL

SELECT 'geolocation', COUNT(*),
       SUM(CASE WHEN dwh_load_ts IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_source_file IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM [olist_stg].[bronze].[geolocation]

UNION ALL

SELECT 'order_items', COUNT(*),
       SUM(CASE WHEN dwh_load_ts IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_source_file IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM [olist_stg].[bronze].[order_items]

UNION ALL

SELECT 'order_payments', COUNT(*),
       SUM(CASE WHEN dwh_load_ts IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_source_file IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM [olist_stg].[bronze].[order_payments]

UNION ALL

SELECT 'order_reviews', COUNT(*),
       SUM(CASE WHEN dwh_load_ts IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_source_file IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM [olist_stg].[bronze].[order_reviews]

UNION ALL

SELECT 'orders', COUNT(*),
       SUM(CASE WHEN dwh_load_ts IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_source_file IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM [olist_stg].[bronze].[orders]

UNION ALL

SELECT 'products', COUNT(*),
       SUM(CASE WHEN dwh_load_ts IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_source_file IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM [olist_stg].[bronze].[products]

UNION ALL

SELECT 'sellers', COUNT(*),
       SUM(CASE WHEN dwh_load_ts IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_source_file IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM [olist_stg].[bronze].[sellers]

UNION ALL

SELECT 'product_category_name_translation', COUNT(*),
       SUM(CASE WHEN dwh_load_ts IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_source_file IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM [olist_stg].[bronze].[product_category_name_translation];
