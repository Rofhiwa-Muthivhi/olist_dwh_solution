USE olist_dwh;

-- i am visually inspecting five transformed order item records
-- expected results: a visual table with a preview of transformation
SELECT TOP 5
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value,
    total_item_value
FROM olist_dwh.silver.order_items
ORDER BY order_id, order_item_id;


-- i am comparing bronze and silver order item row counts
-- 112650 records in both bronze and silver tables
SELECT
    'Bronze' AS layer,
    COUNT(*) AS total_records
FROM olist_stg.bronze.order_items

UNION ALL

SELECT
    'Silver' AS layer,
    COUNT(*) AS total_records
FROM olist_dwh.silver.order_items;


-- i am checking the required data types in the silver order items table
-- expected results: date data type with precisions
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM olist_dwh.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'order_items'
  AND COLUMN_NAME IN (
      'price',
      'freight_value',
      'shipping_limit_date'
  );


-- i am checking whether total item value equals price plus freight value
-- expected results:  0
SELECT *
FROM olist_dwh.silver.order_items
WHERE total_item_value <> (price + freight_value)
   OR total_item_value IS NULL;


-- i am checking for duplicate order item combinations
-- expected results: 0
SELECT
    order_id,
    order_item_id,
    COUNT(*) AS duplicate_count
FROM olist_dwh.silver.order_items
GROUP BY
    order_id,
    order_item_id
HAVING COUNT(*) > 1;


-- i am checking for missing required order item values
-- expected results: 0
SELECT *
FROM olist_dwh.silver.order_items
WHERE order_id IS NULL
   OR order_item_id IS NULL
   OR product_id IS NULL
   OR seller_id IS NULL
   OR price IS NULL
   OR freight_value IS NULL
   OR shipping_limit_date IS NULL;