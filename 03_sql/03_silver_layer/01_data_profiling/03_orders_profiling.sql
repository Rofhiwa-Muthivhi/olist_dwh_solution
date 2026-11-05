USE [olist_stg];
GO

-- checking the total number of records for orders

SELECT
    COUNT(*) AS total_orders
FROM [olist_stg].[bronze].[orders];


-- verifying that each order has a unique order id and identifying any repeated ids

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT order_id) AS unique_order_ids,
    COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_order_ids
FROM [olist_stg].[bronze].[orders];


-- checking for missing values in the order information

SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS null_order_status,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS null_purchase_timestamp,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS null_approved_at,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS null_delivered_carrier_date,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS null_delivered_customer_date,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS null_estimated_delivery_date
FROM [olist_stg].[bronze].[orders];


-- identifying the different order statuses and how frequently they occur

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM [olist_stg].[bronze].[orders]
GROUP BY order_status
ORDER BY total_orders DESC;


-- identifying order statuses with inconsistent casing or unwanted spaces

SELECT DISTINCT order_status
FROM [olist_stg].[bronze].[orders]
WHERE
    order_status <> LTRIM(RTRIM(order_status))
    OR order_status <> LOWER(order_status)
ORDER BY order_status;


-- identifying the earliest and latest purchase dates in the dataset

SELECT
    MIN(order_purchase_timestamp) AS first_purchase_date,
    MAX(order_purchase_timestamp) AS last_purchase_date
FROM [olist_stg].[bronze].[orders];


-- analysing the availability of order timestamps across the different order stages

SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_purchase_timestamp IS NOT NULL THEN 1 ELSE 0 END) AS orders_with_purchase_date,
    SUM(CASE WHEN order_approved_at IS NOT NULL THEN 1 ELSE 0 END) AS orders_with_approval_date,
    SUM(CASE WHEN order_delivered_carrier_date IS NOT NULL THEN 1 ELSE 0 END) AS orders_with_carrier_date,
    SUM(CASE WHEN order_delivered_customer_date IS NOT NULL THEN 1 ELSE 0 END) AS orders_with_delivery_date,
    SUM(CASE WHEN order_estimated_delivery_date IS NOT NULL THEN 1 ELSE 0 END) AS orders_with_estimated_delivery_date
FROM [olist_stg].[bronze].[orders];


-- checking whether order timestamps follow the correct sequence from purchase to customer delivery

SELECT
    order_id,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM [olist_stg].[bronze].[orders]
WHERE
    (order_approved_at IS NOT NULL
        AND order_approved_at < order_purchase_timestamp)

    OR (order_delivered_carrier_date IS NOT NULL
        AND order_delivered_carrier_date < order_purchase_timestamp)

    OR (order_delivered_customer_date IS NOT NULL
        AND order_delivered_carrier_date IS NOT NULL
        AND order_delivered_customer_date < order_delivered_carrier_date);


-- analysing how many orders have been delivered compared to orders with other statuses

SELECT
    CASE
        WHEN order_status = 'delivered' THEN 'delivered'
        ELSE 'not delivered'
    END AS delivery_category,
    COUNT(*) AS total_orders
FROM [olist_stg].[bronze].[orders]
GROUP BY
    CASE
        WHEN order_status = 'delivered' THEN 'delivered'
        ELSE 'not delivered'
    END
ORDER BY total_orders DESC;

