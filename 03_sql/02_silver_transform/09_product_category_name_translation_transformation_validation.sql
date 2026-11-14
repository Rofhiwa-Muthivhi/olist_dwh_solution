
/*
============================================================
  olist data warehouse
  product category translation validation

  source: [olist_stg].[bronze].[product_category_name_translation]
  target: [olist_dwh].[silver].[product_category_name_translation]

  objective:
  compare bronze and silver data to validate the
  transformations implemented according to the
  instructor's requirements.

  required transformations:
  trim category names and english translations,
  identify missing translations,
  handle missing category translations,
  remove duplicate category mappings
============================================================
*/


/*============================================================
  01. record inspection
============================================================*/

-- bronze: inspect original category translation records

SELECT TOP 20
    column1,
    column2
FROM [olist_stg].[bronze].[product_category_name_translation];


-- silver: inspect transformed category translation records

SELECT TOP 20
    product_category_name,
    product_category_name_english
FROM [olist_dwh].[silver].[product_category_name_translation];


/*============================================================
  02. dataset profiling
============================================================*/

-- bronze: profile record counts and null values

SELECT
    COUNT(*) AS total_records,

    COUNT(DISTINCT column1) AS unique_category_names,

    SUM(CASE WHEN column1 IS NULL THEN 1 ELSE 0 END) AS null_category_name,

    SUM(CASE WHEN column2 IS NULL THEN 1 ELSE 0 END) AS null_english_translation

FROM [olist_stg].[bronze].[product_category_name_translation];


-- silver: profile transformed records and compare data completeness

SELECT
    COUNT(*) AS total_records,

    COUNT(DISTINCT product_category_name) AS unique_category_names,

    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS null_category_name,

    SUM(CASE WHEN product_category_name_english IS NULL THEN 1 ELSE 0 END) AS null_english_translation

FROM [olist_dwh].[silver].[product_category_name_translation];


/*============================================================
  03. category profiling
============================================================*/

-- bronze: examine original portuguese category names

SELECT
    column1 AS product_category_name,
    COUNT(*) AS occurrence_count

FROM [olist_stg].[bronze].[product_category_name_translation]

GROUP BY column1

ORDER BY occurrence_count DESC;


-- silver: examine transformed category names

SELECT
    product_category_name,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[product_category_name_translation]

GROUP BY product_category_name

ORDER BY occurrence_count DESC;


-- bronze: examine original english category translations

SELECT
    column2 AS product_category_name_english,
    COUNT(*) AS occurrence_count

FROM [olist_stg].[bronze].[product_category_name_translation]

GROUP BY column2

ORDER BY occurrence_count DESC;


-- silver: examine transformed english category translations

SELECT
    product_category_name_english,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[product_category_name_translation]

GROUP BY product_category_name_english

ORDER BY occurrence_count DESC;


/*============================================================
  04. missing translation validation
============================================================*/

-- bronze: identify categories with missing english translations

SELECT
    COUNT(*) AS missing_translation_records

FROM [olist_stg].[bronze].[product_category_name_translation]

WHERE column2 IS NULL
   OR LTRIM(RTRIM(column2)) = '';


-- silver: identify categories with missing english translations

SELECT
    COUNT(*) AS missing_translation_records

FROM [olist_dwh].[silver].[product_category_name_translation]

WHERE product_category_name_english IS NULL
   OR LTRIM(RTRIM(product_category_name_english)) = '';


/*============================================================
  05. whitespace validation
============================================================*/

-- bronze: identify category names containing leading or trailing spaces

SELECT
    COUNT(*) AS category_names_with_whitespace

FROM [olist_stg].[bronze].[product_category_name_translation]

WHERE column1 <> LTRIM(RTRIM(column1))
   OR column2 <> LTRIM(RTRIM(column2));


-- silver: identify category names containing leading or trailing spaces

-- expected result: zero records

SELECT
    COUNT(*) AS category_names_with_whitespace

FROM [olist_dwh].[silver].[product_category_name_translation]

WHERE product_category_name <> LTRIM(RTRIM(product_category_name))
   OR product_category_name_english <> LTRIM(RTRIM(product_category_name_english));


/*============================================================
  06. duplicate validation
============================================================*/

-- bronze: identify duplicate category mappings

SELECT
    column1,
    column2,
    COUNT(*) AS occurrence_count

FROM [olist_stg].[bronze].[product_category_name_translation]

GROUP BY
    column1,
    column2

HAVING COUNT(*) > 1;


-- silver: identify duplicate category mappings

-- expected result: zero records if duplicates were removed

SELECT
    product_category_name,
    product_category_name_english,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[product_category_name_translation]

GROUP BY
    product_category_name,
    product_category_name_english

HAVING COUNT(*) > 1;


/*============================================================
  07. transformation validation
============================================================*/

-- silver: validate that category names are trimmed

-- expected result: zero records

SELECT
    product_category_name,
    product_category_name_english

FROM [olist_dwh].[silver].[product_category_name_translation]

WHERE product_category_name <> LTRIM(RTRIM(product_category_name))
   OR product_category_name_english <> LTRIM(RTRIM(product_category_name_english));


-- silver: inspect categories without english translations

SELECT
    product_category_name,
    product_category_name_english

FROM [olist_dwh].[silver].[product_category_name_translation]

WHERE product_category_name_english IS NULL
   OR LTRIM(RTRIM(product_category_name_english)) = '';


/*============================================================
  08. record reconciliation
============================================================*/

-- compare bronze and silver record counts

SELECT
    (SELECT COUNT(*)
     FROM [olist_stg].[bronze].[product_category_name_translation]) AS bronze_records,

    (SELECT COUNT(*)
     FROM [olist_dwh].[silver].[product_category_name_translation]) AS silver_records;


-- identify category mappings missing from silver

SELECT
    b.column1,
    b.column2

FROM [olist_stg].[bronze].[product_category_name_translation] AS b

LEFT JOIN [olist_dwh].[silver].[product_category_name_translation] AS s
    ON LTRIM(RTRIM(b.column1)) = s.product_category_name

WHERE s.product_category_name IS NULL;


-- identify unexpected category mappings in silver

SELECT
    s.product_category_name,
    s.product_category_name_english

FROM [olist_dwh].[silver].[product_category_name_translation] AS s

LEFT JOIN [olist_stg].[bronze].[product_category_name_translation] AS b
    ON s.product_category_name = LTRIM(RTRIM(b.column1))

WHERE b.column1 IS NULL;


/*
  validation outcome:
  - original and transformed category translation records were profiled.
  - missing category translations were investigated.
  - category names and translations were checked for whitespace.
  - duplicate category mappings were investigated.
  - bronze and silver category mappings were reconciled.
  - missing and unexpected category mappings were investigated.
  - final transformation results will be confirmed after reviewing the validation queries.
*/
