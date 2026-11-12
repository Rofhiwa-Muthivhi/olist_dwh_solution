USE olist_dwh;

-- i am visually inspecting five transformed category translations
-- expected results: transformation preview table
SELECT TOP 5
    product_category_name,
    product_category_name_english,
    dwh_load_ts
FROM olist_dwh.silver.product_category_name_translation
ORDER BY product_category_name;


-- i am comparing bronze and silver category translation row counts
-- expected results: required datatype and bronze 71 records, silver 73 records
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM olist_dwh.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'product_category_name_translation'
ORDER BY ORDINAL_POSITION;
SELECT
    'Bronze' AS layer,
    COUNT(*) AS total_records
FROM olist_stg.bronze.product_category_name_translation

UNION ALL

SELECT
    'Silver' AS layer,
    COUNT(*) AS total_records
FROM olist_dwh.silver.product_category_name_translation;


-- i am checking for missing Portuguese and English category names

SELECT *
FROM olist_dwh.silver.product_category_name_translation
WHERE product_category_name IS NULL
   OR LTRIM(RTRIM(product_category_name)) = ''
   OR product_category_name_english IS NULL
   OR LTRIM(RTRIM(product_category_name_english)) = '';


-- i am checking for duplicate Portuguese category names
-- expected results: 0
SELECT
    product_category_name,
    COUNT(*) AS duplicate_count
FROM olist_dwh.silver.product_category_name_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;


-- i am checking for duplicate Portuguese and English category combinations
-- expected results: 0
SELECT
    product_category_name,
    product_category_name_english,
    COUNT(*) AS duplicate_count
FROM olist_dwh.silver.product_category_name_translation
GROUP BY
    product_category_name,
    product_category_name_english
HAVING COUNT(*) > 1;


-- i am checking whether the two missing category translations were added
-- expected results: added translations
SELECT *
FROM olist_dwh.silver.product_category_name_translation
WHERE product_category_name IN (
    'pc_gamer',
    'portateis_cozinha_e_preparadores_de_alimentos'
);


-- i am validating the exact english translations
-- expected results: 0
SELECT *
FROM olist_dwh.silver.product_category_name_translation
WHERE
    (product_category_name = 'pc_gamer'
     AND product_category_name_english <> 'PC Gamer')

    OR

    (product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos'
     AND product_category_name_english <> 'Kitchen and Food Preparation Appliances');


-- i am checking for leading or trailing spaces in Portuguese categories
-- expected results: 0
SELECT *
FROM olist_dwh.silver.product_category_name_translation
WHERE product_category_name <> LTRIM(RTRIM(product_category_name));


-- i am checking for leading or trailing spaces in English categories
-- expected results: 0
SELECT *
FROM olist_dwh.silver.product_category_name_translation
WHERE product_category_name_english <>
      LTRIM(RTRIM(product_category_name_english));


-- i am checking the data types of the category translation columns
-- expected results: required data types
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM olist_dwh.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'product_category_name_translation'
ORDER BY ORDINAL_POSITION;