
/*
============================================================
  olist data warehouse
  products validation

  source: [olist_stg].[bronze].[products]
  target: [olist_dwh].[silver].[products]

  objective:
  compare bronze and silver data to validate the
  transformations implemented according to the
  instructor's requirements.

  required transformations:
  correct misspelt column names,
  join english product categories,
  replace missing categories with Unknown
============================================================
*/


/*============================================================
  01. record inspection
============================================================*/

-- bronze: inspect original product records

SELECT TOP 20
    product_id,
    product_category_name,
    product_name_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM [olist_stg].[bronze].[products];


-- silver: inspect transformed product records

SELECT TOP 20
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM [olist_dwh].[silver].[products];


/*============================================================
  02. dataset profiling
============================================================*/

-- bronze: profile record counts and null values

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT product_id) AS unique_product_ids,

    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS null_category_name,
    SUM(CASE WHEN product_name_lenght IS NULL THEN 1 ELSE 0 END) AS null_product_name_length,
    SUM(CASE WHEN product_photos_qty IS NULL THEN 1 ELSE 0 END) AS null_product_photos_qty,
    SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS null_product_weight,
    SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS null_product_length,
    SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) AS null_product_height,
    SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) AS null_product_width

FROM [olist_stg].[bronze].[products];


-- silver: profile transformed records and compare data completeness

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT product_id) AS unique_product_ids,

    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS null_category_name,
    SUM(CASE WHEN product_name_length IS NULL THEN 1 ELSE 0 END) AS null_product_name_length,
    SUM(CASE WHEN product_description_length IS NULL THEN 1 ELSE 0 END) AS null_product_description_length,
    SUM(CASE WHEN product_photos_qty IS NULL THEN 1 ELSE 0 END) AS null_product_photos_qty,
    SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS null_product_weight,
    SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS null_product_length,
    SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) AS null_product_height,
    SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) AS null_product_width

FROM [olist_dwh].[silver].[products];


/*============================================================
  03. category profiling
============================================================*/

-- bronze: examine original product category names

SELECT
    product_category_name,
    COUNT(*) AS occurrence_count

FROM [olist_stg].[bronze].[products]

GROUP BY product_category_name

ORDER BY occurrence_count DESC;


-- silver: examine transformed product category names

SELECT
    product_category_name,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[products]

GROUP BY product_category_name

ORDER BY occurrence_count DESC;


-- bronze: identify products with missing original categories

SELECT
    COUNT(*) AS missing_category_records

FROM [olist_stg].[bronze].[products]

WHERE product_category_name IS NULL;


-- silver: identify products with missing categories

-- expected result: zero records if missing categories are replaced with Unknown

SELECT
    COUNT(*) AS missing_category_records

FROM [olist_dwh].[silver].[products]

WHERE product_category_name IS NULL;


/*============================================================
  04. category translation validation
============================================================*/

-- bronze: inspect distinct original product categories

SELECT DISTINCT
    product_category_name

FROM [olist_stg].[bronze].[products]

WHERE product_category_name IS NOT NULL

ORDER BY product_category_name;


-- silver: inspect distinct transformed product categories

SELECT DISTINCT
    product_category_name

FROM [olist_dwh].[silver].[products]

WHERE product_category_name IS NOT NULL

ORDER BY product_category_name;


/*============================================================
  05. column naming validation
============================================================*/

-- bronze: inspect original misspelled product column

SELECT
    COLUMN_NAME,
    DATA_TYPE

FROM [olist_stg].INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'bronze'
  AND TABLE_NAME = 'products'
  AND COLUMN_NAME = 'product_name_lenght';


-- silver: inspect corrected product column

SELECT
    COLUMN_NAME,
    DATA_TYPE

FROM [olist_dwh].INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'products'
  AND COLUMN_NAME = 'product_name_length';


-- silver: check whether the original misspelled column remains

-- expected result: zero records

SELECT
    COLUMN_NAME

FROM [olist_dwh].INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'products'
  AND COLUMN_NAME = 'product_name_lenght';


/*============================================================
  06. numerical attribute profiling
============================================================*/

-- bronze: inspect original product attribute ranges

SELECT
    MIN(TRY_CONVERT(INT, product_name_lenght)) AS minimum_name_length,
    MAX(TRY_CONVERT(INT, product_name_lenght)) AS maximum_name_length,

    MIN(TRY_CONVERT(INT, product_photos_qty)) AS minimum_photos_qty,
    MAX(TRY_CONVERT(INT, product_photos_qty)) AS maximum_photos_qty,

    MIN(TRY_CONVERT(INT, product_weight_g)) AS minimum_weight,
    MAX(TRY_CONVERT(INT, product_weight_g)) AS maximum_weight,

    MIN(TRY_CONVERT(INT, product_length_cm)) AS minimum_length,
    MAX(TRY_CONVERT(INT, product_length_cm)) AS maximum_length,

    MIN(TRY_CONVERT(INT, product_height_cm)) AS minimum_height,
    MAX(TRY_CONVERT(INT, product_height_cm)) AS maximum_height,

    MIN(TRY_CONVERT(INT, product_width_cm)) AS minimum_width,
    MAX(TRY_CONVERT(INT, product_width_cm)) AS maximum_width

FROM [olist_stg].[bronze].[products];


-- silver: inspect transformed product attribute ranges

SELECT
    MIN(product_name_length) AS minimum_name_length,
    MAX(product_name_length) AS maximum_name_length,

    MIN(product_photos_qty) AS minimum_photos_qty,
    MAX(product_photos_qty) AS maximum_photos_qty,

    MIN(product_weight_g) AS minimum_weight,
    MAX(product_weight_g) AS maximum_weight,

    MIN(product_length_cm) AS minimum_length,
    MAX(product_length_cm) AS maximum_length,

    MIN(product_height_cm) AS minimum_height,
    MAX(product_height_cm) AS maximum_height,

    MIN(product_width_cm) AS minimum_width,
    MAX(product_width_cm) AS maximum_width

FROM [olist_dwh].[silver].[products];


/*============================================================
  07. transformation validation
============================================================*/

-- silver: validate that the corrected product name column exists

-- expected result: one record

SELECT
    COLUMN_NAME

FROM [olist_dwh].INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'products'
  AND COLUMN_NAME = 'product_name_length';


-- silver: validate that the misspelled product name column does not exist

-- expected result: zero records

SELECT
    COLUMN_NAME

FROM [olist_dwh].INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'products'
  AND COLUMN_NAME = 'product_name_lenght';


-- silver: identify products still containing missing categories

-- expected result: zero records if missing categories were replaced with Unknown

SELECT
    product_id,
    product_category_name

FROM [olist_dwh].[silver].[products]

WHERE product_category_name IS NULL
   OR LTRIM(RTRIM(product_category_name)) = '';


-- silver: identify products assigned the Unknown category

SELECT
    COUNT(*) AS unknown_category_records

FROM [olist_dwh].[silver].[products]

WHERE product_category_name = 'Unknown';


/*============================================================
  08. record reconciliation
============================================================*/

-- compare bronze and silver record counts

-- expected result: matching record counts

SELECT
    (SELECT COUNT(*)
     FROM [olist_stg].[bronze].[products]) AS bronze_records,

    (SELECT COUNT(*)
     FROM [olist_dwh].[silver].[products]) AS silver_records;


-- identify product records missing from silver

-- expected result: zero records

SELECT
    b.product_id

FROM [olist_stg].[bronze].[products] AS b

LEFT JOIN [olist_dwh].[silver].[products] AS s
    ON b.product_id = s.product_id

WHERE s.product_id IS NULL;


-- identify unexpected product records in silver

-- expected result: zero records

SELECT
    s.product_id

FROM [olist_dwh].[silver].[products] AS s

LEFT JOIN [olist_stg].[bronze].[products] AS b
    ON s.product_id = b.product_id

WHERE b.product_id IS NULL;


-- identify duplicate product ids in bronze

-- expected result: zero records

SELECT
    product_id,
    COUNT(*) AS occurrence_count

FROM [olist_stg].[bronze].[products]

GROUP BY product_id

HAVING COUNT(*) > 1;


-- identify duplicate product ids in silver

-- expected result: zero records

SELECT
    product_id,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[products]

GROUP BY product_id

HAVING COUNT(*) > 1;


/*
  validation outcome:
  - original and transformed product records were profiled.
  - misspelt column names were checked against the corrected silver columns.
  - product category values were investigated.
  - missing category handling was validated.
  - product numerical attributes were compared.
  - bronze and silver record counts were reconciled.
  - missing, unexpected and duplicate product records were investigated.
  - final transformation results will be confirmed after reviewing the validation queries.
*/
