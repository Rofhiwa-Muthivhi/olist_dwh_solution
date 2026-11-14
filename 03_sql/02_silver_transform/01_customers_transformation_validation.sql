
/*
============================================================
  olist data warehouse
  customer validation

  source: [olist_stg].[bronze].[customers]
  target: [olist_dwh].[silver].[customers]

  objective:
  compare bronze and silver data to validate the
  transformations implemented according to the
  instructor's requirements.
  
  required transformations:
  trim, proper-case city, upper-case state,
  pad zip prefix to 5 chars
============================================================
*/


/*============================================================
  01. record inspection
============================================================*/

-- bronze: inspect original customer records

SELECT TOP 20
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM [olist_stg].[bronze].[customers];


-- silver: inspect transformed customer records

SELECT TOP 20
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM [olist_dwh].[silver].[customers];


/*============================================================
  02. dataset profiling
============================================================*/

-- bronze: profile record counts, uniqueness and null values

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,
    COUNT(DISTINCT customer_unique_id) AS unique_customer_unique_ids,

    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) AS null_customer_unique_id,
    SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN customer_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_zip_prefix

FROM [olist_stg].[bronze].[customers];


-- silver: profile transformed records and compare data completeness

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,
    COUNT(DISTINCT customer_unique_id) AS unique_customer_unique_ids,

    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) AS null_customer_unique_id,
    SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN customer_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_zip_prefix

FROM [olist_dwh].[silver].[customers];


/*============================================================
  03. whitespace standardisation
============================================================*/

-- bronze: identify records containing leading or trailing spaces

SELECT
    COUNT(*) AS records_with_whitespace

FROM [olist_stg].[bronze].[customers]

WHERE
    customer_city <> LTRIM(RTRIM(customer_city))
    OR customer_state <> LTRIM(RTRIM(customer_state))
    OR customer_zip_code_prefix <> LTRIM(RTRIM(customer_zip_code_prefix));


-- silver: confirm that leading and trailing spaces were removed

-- expected result: zero records with remaining whitespace

SELECT
    COUNT(*) AS records_with_remaining_whitespace

FROM [olist_dwh].[silver].[customers]

WHERE
    customer_city <> LTRIM(RTRIM(customer_city))
    OR customer_state <> LTRIM(RTRIM(customer_state))
    OR customer_zip_code_prefix <> LTRIM(RTRIM(customer_zip_code_prefix));


/*============================================================
  04. city standardisation
============================================================*/

-- bronze: examine original city naming conventions

SELECT
    customer_city,
    COUNT(*) AS occurrence_count

FROM [olist_stg].[bronze].[customers]

GROUP BY customer_city

ORDER BY occurrence_count DESC;


-- silver: examine transformed city naming conventions

SELECT
    customer_city,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[customers]

GROUP BY customer_city

ORDER BY occurrence_count DESC;


/*============================================================
  05. state standardisation
============================================================*/

-- bronze: examine original state abbreviations

SELECT
    customer_state,
    COUNT(*) AS occurrence_count

FROM [olist_stg].[bronze].[customers]

GROUP BY customer_state

ORDER BY occurrence_count DESC;


-- silver: examine standardised state abbreviations

SELECT
    customer_state,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[customers]

GROUP BY customer_state

ORDER BY occurrence_count DESC;


-- silver: identify state values that are not uppercase

-- expected result: zero failed records

SELECT
    COUNT(*) AS failed_records

FROM [olist_dwh].[silver].[customers]

WHERE customer_state <> UPPER(customer_state);


/*============================================================
  06. zip prefix standardisation
============================================================*/

-- bronze: examine original zip prefix lengths

SELECT
    LEN(customer_zip_code_prefix) AS zip_length,
    COUNT(*) AS occurrence_count

FROM [olist_stg].[bronze].[customers]

GROUP BY LEN(customer_zip_code_prefix)

ORDER BY zip_length;


-- silver: examine transformed zip prefix lengths

SELECT
    LEN(customer_zip_code_prefix) AS zip_length,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[customers]

GROUP BY LEN(customer_zip_code_prefix)

ORDER BY zip_length;


-- silver: identify zip prefixes that are not five characters long

-- expected result: zero failed records

SELECT
    COUNT(*) AS failed_records

FROM [olist_dwh].[silver].[customers]

WHERE customer_zip_code_prefix IS NOT NULL
  AND LEN(customer_zip_code_prefix) <> 5;


/*============================================================
  07. transformation validation
============================================================*/

-- silver: validate that city, state and zip values are trimmed

-- expected result: zero failed records

SELECT
    COUNT(*) AS failed_records

FROM [olist_dwh].[silver].[customers]

WHERE
    customer_city <> LTRIM(RTRIM(customer_city))
    OR customer_state <> LTRIM(RTRIM(customer_state))
    OR customer_zip_code_prefix <> LTRIM(RTRIM(customer_zip_code_prefix));


/*============================================================
  08. record reconciliation
============================================================*/

-- compare bronze and silver record counts

-- expected result: matching record counts

SELECT
    (SELECT COUNT(*)
     FROM [olist_stg].[bronze].[customers]) AS bronze_records,

    (SELECT COUNT(*)
     FROM [olist_dwh].[silver].[customers]) AS silver_records;


-- identify customer records missing from silver

-- expected result: zero records

SELECT
    b.customer_id

FROM [olist_stg].[bronze].[customers] AS b

LEFT JOIN [olist_dwh].[silver].[customers] AS s
    ON b.customer_id = s.customer_id

WHERE s.customer_id IS NULL;


-- identify unexpected customer records in silver

-- expected result: zero records

SELECT
    s.customer_id

FROM [olist_dwh].[silver].[customers] AS s

LEFT JOIN [olist_stg].[bronze].[customers] AS b
    ON s.customer_id = b.customer_id

WHERE b.customer_id IS NULL;

/*
  validation outcome:
  - the customer dataset was relatively clean in bronze.
  - no major data complications were identified during profiling.
  - whitespace, city casing, state casing and zip prefix requirements were validated.
  - some transformations did not result in visible changes because the original data already met the required standards.
  - overall, the silver customer dataset meets the instructor's transformation requirements.
*/