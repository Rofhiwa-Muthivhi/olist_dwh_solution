USE olist_stg;
GO

-- checking the latest ingestion batch

SELECT *
FROM etl.load_log
WHERE batch_id = (SELECT MAX(batch_id) FROM etl.load_log)
ORDER BY load_log_id;




-- checking bronze table record counts against the etl log

SELECT 'customers' AS dataset,
       (SELECT COUNT(*) FROM bronze.customers) AS bronze_records,
       (SELECT rows_loaded FROM etl.load_log
        WHERE source_file = 'olist_customers_dataset.csv'
        AND batch_id = (SELECT MAX(batch_id) FROM etl.load_log)) AS logged_records

UNION ALL

SELECT 'geolocation',
       (SELECT COUNT(*) FROM bronze.geolocation),
       (SELECT rows_loaded FROM etl.load_log
        WHERE source_file = 'olist_geolocation_dataset.csv'
        AND batch_id = (SELECT MAX(batch_id) FROM etl.load_log))

UNION ALL

SELECT 'order_items',
       (SELECT COUNT(*) FROM bronze.order_items),
       (SELECT rows_loaded FROM etl.load_log
        WHERE source_file = 'olist_order_items_dataset.csv'
        AND batch_id = (SELECT MAX(batch_id) FROM etl.load_log))

UNION ALL

SELECT 'order_payments',
       (SELECT COUNT(*) FROM bronze.order_payments),
       (SELECT rows_loaded FROM etl.load_log
        WHERE source_file = 'olist_order_payments_dataset.csv'
        AND batch_id = (SELECT MAX(batch_id) FROM etl.load_log))

UNION ALL

SELECT 'order_reviews',
       (SELECT COUNT(*) FROM bronze.order_reviews),
       (SELECT rows_loaded FROM etl.load_log
        WHERE source_file = 'olist_order_reviews_dataset.csv'
        AND batch_id = (SELECT MAX(batch_id) FROM etl.load_log))

UNION ALL

SELECT 'orders',
       (SELECT COUNT(*) FROM bronze.orders),
       (SELECT rows_loaded FROM etl.load_log
        WHERE source_file = 'olist_orders_dataset.csv'
        AND batch_id = (SELECT MAX(batch_id) FROM etl.load_log))

UNION ALL

SELECT 'products',
       (SELECT COUNT(*) FROM bronze.products),
       (SELECT rows_loaded FROM etl.load_log
        WHERE source_file = 'olist_products_dataset.csv'
        AND batch_id = (SELECT MAX(batch_id) FROM etl.load_log))

UNION ALL

SELECT 'sellers',
       (SELECT COUNT(*) FROM bronze.sellers),
       (SELECT rows_loaded FROM etl.load_log
        WHERE source_file = 'olist_sellers_dataset.csv'
        AND batch_id = (SELECT MAX(batch_id) FROM etl.load_log))

UNION ALL

SELECT 'product_category_name_translation',
       (SELECT COUNT(*) FROM bronze.product_category_name_translation),
       (SELECT rows_loaded FROM etl.load_log
        WHERE source_file = 'product_category_name_translation.csv'
        AND batch_id = (SELECT MAX(batch_id) FROM etl.load_log));



-- checking whether metadata columns contain null values

SELECT 'customers' AS dataset,
       COUNT(*) AS total_records,
       SUM(CASE WHEN dwh_load_ts IS NULL THEN 1 ELSE 0 END) AS missing_load_ts,
       SUM(CASE WHEN dwh_source_file IS NULL THEN 1 ELSE 0 END) AS missing_source_file,
       SUM(CASE WHEN dwh_batch_id IS NULL THEN 1 ELSE 0 END) AS missing_batch_id
FROM bronze.customers

UNION ALL

SELECT 'geolocation', COUNT(*),
       SUM(CASE WHEN dwh_load_ts IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_source_file IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM bronze.geolocation

UNION ALL

SELECT 'order_items', COUNT(*),
       SUM(CASE WHEN dwh_load_ts IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_source_file IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM bronze.order_items

UNION ALL

SELECT 'order_payments', COUNT(*),
       SUM(CASE WHEN dwh_load_ts IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_source_file IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM bronze.order_payments

UNION ALL

SELECT 'order_reviews', COUNT(*),
       SUM(CASE WHEN dwh_load_ts IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_source_file IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM bronze.order_reviews

UNION ALL

SELECT 'orders', COUNT(*),
       SUM(CASE WHEN dwh_load_ts IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_source_file IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM bronze.orders

UNION ALL

SELECT 'products', COUNT(*),
       SUM(CASE WHEN dwh_load_ts IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_source_file IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM bronze.products

UNION ALL

SELECT 'sellers', COUNT(*),
       SUM(CASE WHEN dwh_load_ts IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_source_file IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM bronze.sellers

UNION ALL

SELECT 'product_category_name_translation', COUNT(*),
       SUM(CASE WHEN dwh_load_ts IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_source_file IS NULL THEN 1 ELSE 0 END),
       SUM(CASE WHEN dwh_batch_id IS NULL THEN 1 ELSE 0 END)
FROM bronze.product_category_name_translation;