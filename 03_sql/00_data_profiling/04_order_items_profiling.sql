USE [olist_stg];
GO

-- checking the total number of records for order items

SELECT
    COUNT(*) AS total_order_items
FROM [olist_stg].[bronze].[order_items];


-- checking the number of columns in the order items table

SELECT COUNT(*) AS total_columns
FROM [olist_stg].[INFORMATION_SCHEMA].[COLUMNS]
WHERE TABLE_SCHEMA = 'bronze'
AND TABLE_NAME = 'order_items';


-- checking whether each order item has a unique combination of order id and item id

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT CONCAT(order_id, '-', order_item_id)) AS unique_order_items
FROM [olist_stg].[bronze].[order_items];


-- checking for missing values in the order item information

SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN order_item_id IS NULL THEN 1 ELSE 0 END) AS null_order_item_id,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
    SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) AS null_shipping_limit_date,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS null_freight_value
FROM [olist_stg].[bronze].[order_items];


-- analysing how many items are included in each order

SELECT
    order_id,
    COUNT(*) AS total_items
FROM [olist_stg].[bronze].[order_items]
GROUP BY order_id
ORDER BY total_items DESC;


-- checking the minimum, maximum and average product prices and freight costs

SELECT
    MIN(TRY_CONVERT(DECIMAL(10,2), price)) AS minimum_product_price,
    MAX(TRY_CONVERT(DECIMAL(10,2), price)) AS maximum_product_price,
    AVG(TRY_CONVERT(DECIMAL(10,2), price)) AS average_product_price,
    MIN(TRY_CONVERT(DECIMAL(10,2), freight_value)) AS minimum_freight_cost,
    MAX(TRY_CONVERT(DECIMAL(10,2), freight_value)) AS maximum_freight_cost,
    AVG(TRY_CONVERT(DECIMAL(10,2), freight_value)) AS average_freight_cost
FROM [olist_stg].[bronze].[order_items];


-- identifying order items with zero or negative prices and freight values

SELECT
    order_id,
    order_item_id,
    price,
    freight_value
FROM [olist_stg].[bronze].[order_items]
WHERE
    TRY_CONVERT(DECIMAL(10,2), price) <= 0
    OR TRY_CONVERT(DECIMAL(10,2), freight_value) < 0;


-- identifying the earliest and latest shipping limit dates recorded for order items

SELECT
    MIN(shipping_limit_date) AS earliest_shipping_limit,
    MAX(shipping_limit_date) AS latest_shipping_limit
FROM [olist_stg].[bronze].[order_items];


-- identifying order items with shipping limit dates earlier than their purchase dates

SELECT
    oi.order_id,
    oi.order_item_id,
    o.order_purchase_timestamp,
    oi.shipping_limit_date
FROM [olist_stg].[bronze].[order_items] oi
INNER JOIN [olist_stg].[bronze].[orders] o
    ON oi.order_id = o.order_id
WHERE oi.shipping_limit_date < o.order_purchase_timestamp;


-- analysing how many order items are associated with each seller

SELECT
    seller_id,
    COUNT(*) AS total_order_items
FROM [olist_stg].[bronze].[order_items]
GROUP BY seller_id
ORDER BY total_order_items DESC;