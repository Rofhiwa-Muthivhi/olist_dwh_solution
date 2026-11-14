
/*
============================================================
  olist data warehouse
  seller validation

  source: [olist_stg].[bronze].[sellers]
  target: [olist_dwh].[silver].[sellers]

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

-- bronze: inspect original seller records

SELECT TOP 20
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM [olist_stg].[bronze].[sellers];


-- silver: inspect transformed seller records

SELECT TOP 20
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM [olist_dwh].[silver].[sellers];


/*============================================================
  02. dataset profiling
============================================================*/

-- bronze: profile record counts, uniqueness and null values

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT seller_id) AS unique_seller_ids,

    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
    SUM(CASE WHEN seller_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_zip_prefix,
    SUM(CASE WHEN seller_city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN seller_state IS NULL THEN 1 ELSE 0 END) AS null_state

FROM [olist_stg].[bronze].[sellers];


-- silver: profile transformed records and compare data completeness

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT seller_id) AS unique_seller_ids,

    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
    SUM(CASE WHEN seller_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_zip_prefix,
    SUM(CASE WHEN seller_city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN seller_state IS NULL THEN 1 ELSE 0 END) AS null_state

FROM [olist_dwh].[silver].[sellers];


/*============================================================
  03. whitespace standardisation
============================================================*/

-- bronze: identify records containing leading or trailing spaces

SELECT
    COUNT(*) AS records_with_whitespace

FROM [olist_stg].[bronze].[sellers]

WHERE
    seller_city <> LTRIM(RTRIM(seller_city))
    OR seller_state <> LTRIM(RTRIM(seller_state))
    OR seller_zip_code_prefix <> LTRIM(RTRIM(seller_zip_code_prefix));


-- silver: confirm that leading and trailing spaces were removed

-- expected result: zero records with remaining whitespace

SELECT
    COUNT(*) AS records_with_remaining_whitespace

FROM [olist_dwh].[silver].[sellers]

WHERE
    seller_city <> LTRIM(RTRIM(seller_city))
    OR seller_state <> LTRIM(RTRIM(seller_state))
    OR seller_zip_code_prefix <> LTRIM(RTRIM(seller_zip_code_prefix));


/*============================================================
  04. city standardisation
============================================================*/

-- bronze: examine original city naming conventions

SELECT
    seller_city,
    COUNT(*) AS occurrence_count

FROM [olist_stg].[bronze].[sellers]

GROUP BY seller_city

ORDER BY occurrence_count DESC;


-- silver: examine transformed city naming conventions

SELECT
    seller_city,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[sellers]

GROUP BY seller_city

ORDER BY occurrence_count DESC;


/*============================================================
  05. state standardisation
============================================================*/

-- bronze: examine original state abbreviations

SELECT
    seller_state,
    COUNT(*) AS occurrence_count

FROM [olist_stg].[bronze].[sellers]

GROUP BY seller_state

ORDER BY occurrence_count DESC;


-- silver: examine standardised state abbreviations

SELECT
    seller_state,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[sellers]

GROUP BY seller_state

ORDER BY occurrence_count DESC;


-- silver: identify state values that are not uppercase

-- expected result: zero failed records

SELECT
    COUNT(*) AS failed_records

FROM [olist_dwh].[silver].[sellers]

WHERE seller_state <> UPPER(seller_state);


/*============================================================
  06. zip prefix standardisation
============================================================*/

-- bronze: examine original zip prefix lengths

SELECT
    LEN(seller_zip_code_prefix) AS zip_length,
    COUNT(*) AS occurrence_count

FROM [olist_stg].[bronze].[sellers]

GROUP BY LEN(seller_zip_code_prefix)

ORDER BY zip_length;


-- silver: examine transformed zip prefix lengths

SELECT
    LEN(seller_zip_code_prefix) AS zip_length,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[sellers]

GROUP BY LEN(seller_zip_code_prefix)

ORDER BY zip_length;


-- silver: identify zip prefixes that are not five characters long

-- expected result: zero failed records

SELECT
    COUNT(*) AS failed_records

FROM [olist_dwh].[silver].[sellers]

WHERE seller_zip_code_prefix IS NOT NULL
  AND LEN(seller_zip_code_prefix) <> 5;


/*============================================================
  07. transformation validation
============================================================*/

-- silver: validate that city, state and zip values are trimmed

-- expected result: zero failed records

SELECT
    COUNT(*) AS failed_records

FROM [olist_dwh].[silver].[sellers]

WHERE
    seller_city <> LTRIM(RTRIM(seller_city))
    OR seller_state <> LTRIM(RTRIM(seller_state))
    OR seller_zip_code_prefix <> LTRIM(RTRIM(seller_zip_code_prefix));


/*============================================================
  08. record reconciliation
============================================================*/

-- compare bronze and silver record counts

-- expected result: matching record counts

SELECT
    (SELECT COUNT(*)
     FROM [olist_stg].[bronze].[sellers]) AS bronze_records,

    (SELECT COUNT(*)
     FROM [olist_dwh].[silver].[sellers]) AS silver_records;


-- identify seller records missing from silver

-- expected result: zero records

SELECT
    b.seller_id

FROM [olist_stg].[bronze].[sellers] AS b

LEFT JOIN [olist_dwh].[silver].[sellers] AS s
    ON b.seller_id = s.seller_id

WHERE s.seller_id IS NULL;


-- identify unexpected seller records in silver

-- expected result: zero records

SELECT
    s.seller_id

FROM [olist_dwh].[silver].[sellers] AS s

LEFT JOIN [olist_stg].[bronze].[sellers] AS b
    ON s.seller_id = b.seller_id

WHERE b.seller_id IS NULL;


-- identify duplicate seller ids in silver

-- expected result: zero records

SELECT
    seller_id,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[sellers]

GROUP BY seller_id

HAVING COUNT(*) > 1;


/*
  validation outcome:
  - the seller dataset was profiled to establish its original condition.
  - whitespace, city casing, state casing and zip prefix requirements were investigated.
  - bronze and silver records were compared to check data completeness.
  - record reconciliation was performed to identify missing or unexpected seller records.
  - final transformation results will be confirmed after reviewing the validation queries.
*/
