USE olist_dwh;

-- i am visually inspecting five transformed product records
-- expected results: transformation preview table
SELECT TOP 5
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM olist_dwh.silver.products
ORDER BY product_id;


-- i am comparing bronze and silver product row counts
-- expected results: 32951 records in both bronze and silver
SELECT
    'Bronze' AS layer,
    COUNT(*) AS total_records
FROM olist_stg.bronze.products

UNION ALL

SELECT
    'Silver' AS layer,
    COUNT(*) AS total_records
FROM olist_dwh.silver.products;


-- i am checking whether the corrected product column names exist
-- expected results: spelling changes on columns
SELECT
    COLUMN_NAME
FROM olist_dwh.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'products'
  AND COLUMN_NAME IN (
      'product_name_length',
      'product_description_length'
  );


  -- i am checking whether the original misspelled column names are absent
  -- expected results: 0
SELECT
    COLUMN_NAME
FROM olist_dwh.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'products'
  AND COLUMN_NAME IN (
      'product_name_lenght',
      'product_description_lenght'
  );


-- i am checking the data types of the product numeric columns
-- expected results: matching data type to silver table design
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM olist_dwh.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'products'
  AND COLUMN_NAME IN (
      'product_name_length',
      'product_description_length',
      'product_photos_qty',
      'product_weight_g',
      'product_length_cm',
      'product_height_cm',
      'product_width_cm'
  )
ORDER BY COLUMN_NAME;


-- i am checking for missing original product categories
-- expected results: 0
SELECT *
FROM olist_dwh.silver.products
WHERE product_category_name IS NULL
   OR LTRIM(RTRIM(product_category_name)) = '';


-- i am checking for missing product identifiers
-- expected results: 0
SELECT *
FROM olist_dwh.silver.products
WHERE product_id IS NULL
   OR LTRIM(RTRIM(product_id)) = '';


-- i am checking for duplicate product identifiers
-- expected results: 0
SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM olist_dwh.silver.products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- i am checking for missing numeric product attributes
-- expected results: null or missing values summary
SELECT
    COUNT(*) AS total_records,

    SUM(CASE WHEN product_name_length IS NULL
        THEN 1 ELSE 0 END) AS missing_name_length,

    SUM(CASE WHEN product_description_length IS NULL
        THEN 1 ELSE 0 END) AS missing_description_length,

    SUM(CASE WHEN product_photos_qty IS NULL
        THEN 1 ELSE 0 END) AS missing_photos_qty,

    SUM(CASE WHEN product_weight_g IS NULL
        THEN 1 ELSE 0 END) AS missing_weight,

    SUM(CASE WHEN product_length_cm IS NULL
        THEN 1 ELSE 0 END) AS missing_length,

    SUM(CASE WHEN product_height_cm IS NULL
        THEN 1 ELSE 0 END) AS missing_height,

    SUM(CASE WHEN product_width_cm IS NULL
        THEN 1 ELSE 0 END) AS missing_width

FROM olist_dwh.silver.products;