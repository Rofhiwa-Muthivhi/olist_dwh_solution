USE olist_dwh;

-- i am visually inspecting five transformed order records
-- expected results: a visual table showing tranformation preview
SELECT TOP 5
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    is_delivered
FROM olist_dwh.silver.orders
ORDER BY order_purchase_timestamp;


-- i am comparing the bronze and silver orders row counts
-- expected results: 99441 on both bronze and silver tables
SELECT
    'Bronze' AS layer,
    COUNT(*) AS total_records
FROM olist_stg.bronze.orders

UNION ALL

SELECT
    'Silver' AS layer,
    COUNT(*) AS total_records
FROM olist_dwh.silver.orders;


-- i am checking whether all order timestamp columns use datetime2
-- expected results: datetime2 datatype
SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM olist_dwh.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'orders'
  AND COLUMN_NAME IN (
      'order_purchase_timestamp',
      'order_approved_at',
      'order_delivered_carrier_date',
      'order_delivered_customer_date',
      'order_estimated_delivery_date'
  );


-- i am checking whether all order statuses are uppercase
-- expected results: 0 if all records are uppercase
SELECT *
FROM olist_dwh.silver.orders
WHERE order_status <> UPPER(order_status);


-- i am inspecting the standardised order status categories
-- expected results: all order status(uppercase)
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM olist_dwh.silver.orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- i am checking whether the delivery flag agrees with the order status
-- expected results: 0
SELECT *
FROM olist_dwh.silver.orders
WHERE (order_status = 'DELIVERED' AND is_delivered <> 1)
   OR (order_status <> 'DELIVERED' AND is_delivered <> 0)
   OR is_delivered IS NULL;


-- i am checking the distribution of the delivery flag
-- expected results: bit 0 and 1 for yes or no
SELECT
    is_delivered,
    COUNT(*) AS total_orders
FROM olist_dwh.silver.orders
GROUP BY is_delivered;


-- i am checking for missing order identifiers
-- expected results: 0
SELECT *
FROM olist_dwh.silver.orders
WHERE order_id IS NULL
   OR LTRIM(RTRIM(order_id)) = '';


-- i am checking for duplicate order identifiers
-- expected results:  0
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM olist_dwh.silver.orders
GROUP BY order_id
HAVING COUNT(*) > 1;