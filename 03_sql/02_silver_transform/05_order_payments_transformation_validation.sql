USE olist_dwh;


-- i am visually inspecting five transformed payment records
-- expected results: transformation preview table
SELECT TOP 5
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM olist_dwh.silver.order_payments
ORDER BY order_id, payment_sequential;


-- i am comparing bronze and silver payment row counts
-- expected results: 103886 records in both bronze and silver tables
SELECT
    'Bronze' AS layer,
    COUNT(*) AS total_records
FROM olist_stg.bronze.order_payments

UNION ALL

SELECT
    'Silver' AS layer,
    COUNT(*) AS total_records
FROM olist_dwh.silver.order_payments;


-- i am checking the required data types in the silver payments table
-- expected results: required datatypes
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM olist_dwh.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'order_payments'
  AND COLUMN_NAME IN (
      'payment_sequential',
      'payment_type',
      'payment_installments',
      'payment_value'
  );


-- i am inspecting the standardised payment type categories
-- expected results: correct standardisation
SELECT
    payment_type,
    COUNT(*) AS total_records
FROM olist_dwh.silver.order_payments
GROUP BY payment_type
ORDER BY total_records DESC;


-- i am checking whether not_defined was replaced with Unknown
-- expected results: 0
SELECT *
FROM olist_dwh.silver.order_payments
WHERE LOWER(LTRIM(RTRIM(payment_type))) = 'not_defined';


-- i am checking for missing payment types
-- expected results: 0
SELECT *
FROM olist_dwh.silver.order_payments
WHERE payment_type IS NULL
   OR LTRIM(RTRIM(payment_type)) = '';


-- i am checking for duplicate payment records
-- expected results: 0
SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS duplicate_count
FROM olist_dwh.silver.order_payments
GROUP BY
    order_id,
    payment_sequential
HAVING COUNT(*) > 1;


-- i am checking for missing required payment values
-- expected results: 0
SELECT *
FROM olist_dwh.silver.order_payments
WHERE order_id IS NULL
   OR LTRIM(RTRIM(order_id)) = ''
   OR payment_sequential IS NULL
   OR payment_type IS NULL
   OR payment_installments IS NULL
   OR payment_value IS NULL;