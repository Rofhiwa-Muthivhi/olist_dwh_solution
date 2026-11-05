USE [olist_stg];
GO

-- checking the total number of records for category translations

SELECT
    COUNT(*) AS total_translation_records
FROM [olist_stg].[bronze].[product_category_name_translation];


-- viewing the original product categories alongside their english translations

SELECT
    Column1 AS product_category_name,
    Column2 AS product_category_name_english
FROM [olist_stg].[bronze].[product_category_name_translation];


-- checking for missing original category names and english translations

SELECT
    SUM(CASE WHEN Column1 IS NULL OR LTRIM(RTRIM(Column1)) = '' THEN 1 ELSE 0 END) AS missing_original_categories,
    SUM(CASE WHEN Column2 IS NULL OR LTRIM(RTRIM(Column2)) = '' THEN 1 ELSE 0 END) AS missing_english_translations
FROM [olist_stg].[bronze].[product_category_name_translation];


-- identifying original product categories that appear more than once

SELECT
    Column1 AS product_category_name,
    COUNT(*) AS total_records
FROM [olist_stg].[bronze].[product_category_name_translation]
GROUP BY Column1
HAVING COUNT(*) > 1
ORDER BY total_records DESC;


-- identifying english category names associated with multiple original categories

SELECT
    Column2 AS product_category_name_english,
    COUNT(*) AS total_records
FROM [olist_stg].[bronze].[product_category_name_translation]
GROUP BY Column2
HAVING COUNT(*) > 1
ORDER BY total_records DESC;


-- identifying original category names and english translations with unwanted spaces

SELECT
    Column1,
    Column2
FROM [olist_stg].[bronze].[product_category_name_translation]
WHERE
    Column1 <> LTRIM(RTRIM(Column1))
    OR Column2 <> LTRIM(RTRIM(Column2));


-- checking whether original product categories have consistent english translations

SELECT
    Column1 AS product_category_name,
    COUNT(DISTINCT Column2) AS total_english_translations
FROM [olist_stg].[bronze].[product_category_name_translation]
GROUP BY Column1
HAVING COUNT(DISTINCT Column2) > 1;


-- identifying product categories that do not have a matching english translation

SELECT DISTINCT
    p.product_category_name
FROM [olist_stg].[bronze].[products] p
LEFT JOIN [olist_stg].[bronze].[product_category_name_translation] t
    ON LTRIM(RTRIM(p.product_category_name)) = LTRIM(RTRIM(t.Column1))
WHERE
    p.product_category_name IS NOT NULL
    AND LTRIM(RTRIM(p.product_category_name)) <> ''
    AND t.Column1 IS NULL;

