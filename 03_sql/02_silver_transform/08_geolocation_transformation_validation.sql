
/*
============================================================
  olist data warehouse
  geolocation validation

  source: [olist_stg].[bronze].[geolocation]
  target: [olist_dwh].[silver].[geolocation]

  objective:
  compare bronze and silver data to validate the
  transformations implemented according to the
  instructor's requirements.

  required transformations:
  aggregate geolocation records by zip code prefix,
  calculate average latitude and longitude,
  identify the most frequent city,
  retain one record per zip code prefix
============================================================
*/


/*============================================================
  01. record inspection
============================================================*/

-- bronze: inspect original geolocation records

SELECT TOP 20
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
FROM [olist_stg].[bronze].[geolocation];


-- silver: inspect aggregated geolocation records

SELECT TOP 20
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
FROM [olist_dwh].[silver].[geolocation];


/*============================================================
  02. dataset profiling
============================================================*/

-- bronze: profile record counts and null values

SELECT
    COUNT(*) AS total_records,

    COUNT(DISTINCT geolocation_zip_code_prefix) AS unique_zip_prefixes,

    SUM(CASE WHEN geolocation_zip_code_prefix IS NULL
        THEN 1 ELSE 0 END) AS null_zip_prefix,

    SUM(CASE WHEN geolocation_lat IS NULL
        THEN 1 ELSE 0 END) AS null_latitude,

    SUM(CASE WHEN geolocation_lng IS NULL
        THEN 1 ELSE 0 END) AS null_longitude,

    SUM(CASE WHEN geolocation_city IS NULL
        THEN 1 ELSE 0 END) AS null_city,

    SUM(CASE WHEN geolocation_state IS NULL
        THEN 1 ELSE 0 END) AS null_state

FROM [olist_stg].[bronze].[geolocation];


-- silver: profile aggregated records and compare data completeness

SELECT
    COUNT(*) AS total_records,

    COUNT(DISTINCT geolocation_zip_code_prefix) AS unique_zip_prefixes,

    SUM(CASE WHEN geolocation_zip_code_prefix IS NULL
        THEN 1 ELSE 0 END) AS null_zip_prefix,

    SUM(CASE WHEN geolocation_lat IS NULL
        THEN 1 ELSE 0 END) AS null_latitude,

    SUM(CASE WHEN geolocation_lng IS NULL
        THEN 1 ELSE 0 END) AS null_longitude,

    SUM(CASE WHEN geolocation_city IS NULL
        THEN 1 ELSE 0 END) AS null_city,

    SUM(CASE WHEN geolocation_state IS NULL
        THEN 1 ELSE 0 END) AS null_state

FROM [olist_dwh].[silver].[geolocation];


/*============================================================
  03. zip code prefix profiling
============================================================*/

-- bronze: examine the number of records per zip code prefix

SELECT
    geolocation_zip_code_prefix,
    COUNT(*) AS occurrence_count

FROM [olist_stg].[bronze].[geolocation]

GROUP BY geolocation_zip_code_prefix

ORDER BY occurrence_count DESC;


-- silver: examine records per zip code prefix

-- expected result: one record per zip code prefix

SELECT
    geolocation_zip_code_prefix,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[geolocation]

GROUP BY geolocation_zip_code_prefix

ORDER BY occurrence_count DESC;


/*============================================================
  04. coordinate profiling
============================================================*/

-- bronze: inspect original latitude and longitude ranges

SELECT
    MIN(TRY_CONVERT(FLOAT, geolocation_lat)) AS minimum_latitude,
    MAX(TRY_CONVERT(FLOAT, geolocation_lat)) AS maximum_latitude,

    MIN(TRY_CONVERT(FLOAT, geolocation_lng)) AS minimum_longitude,
    MAX(TRY_CONVERT(FLOAT, geolocation_lng)) AS maximum_longitude,

    AVG(TRY_CONVERT(FLOAT, geolocation_lat)) AS average_latitude,
    AVG(TRY_CONVERT(FLOAT, geolocation_lng)) AS average_longitude

FROM [olist_stg].[bronze].[geolocation];


-- silver: inspect aggregated latitude and longitude ranges

SELECT
    MIN(geolocation_lat) AS minimum_latitude,
    MAX(geolocation_lat) AS maximum_latitude,

    MIN(geolocation_lng) AS minimum_longitude,
    MAX(geolocation_lng) AS maximum_longitude,

    AVG(geolocation_lat) AS average_latitude,
    AVG(geolocation_lng) AS average_longitude

FROM [olist_dwh].[silver].[geolocation];


/*============================================================
  05. city profiling
============================================================*/

-- bronze: examine the most frequently occurring cities

SELECT TOP 20
    geolocation_city,
    COUNT(*) AS occurrence_count

FROM [olist_stg].[bronze].[geolocation]

GROUP BY geolocation_city

ORDER BY occurrence_count DESC;


-- silver: examine the distribution of aggregated cities

SELECT
    geolocation_city,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[geolocation]

GROUP BY geolocation_city

ORDER BY occurrence_count DESC;


/*============================================================
  06. aggregation validation
============================================================*/

-- bronze: calculate the average coordinates per zip code prefix

SELECT
    geolocation_zip_code_prefix,

    AVG(TRY_CONVERT(FLOAT, geolocation_lat)) AS average_latitude,

    AVG(TRY_CONVERT(FLOAT, geolocation_lng)) AS average_longitude,

    COUNT(*) AS original_record_count

FROM [olist_stg].[bronze].[geolocation]

GROUP BY geolocation_zip_code_prefix;


-- silver: inspect the aggregated coordinates per zip code prefix

SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng

FROM [olist_dwh].[silver].[geolocation];


/*============================================================
  07. transformation validation
============================================================*/

-- silver: identify duplicate zip code prefixes

-- expected result: zero records

SELECT
    geolocation_zip_code_prefix,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[geolocation]

GROUP BY geolocation_zip_code_prefix

HAVING COUNT(*) > 1;


-- silver: compare stored coordinates against bronze averages

-- expected result: zero records if averages were calculated correctly

WITH bronze_averages AS
(
    SELECT
        geolocation_zip_code_prefix,

        AVG(TRY_CONVERT(FLOAT, geolocation_lat)) AS average_latitude,

        AVG(TRY_CONVERT(FLOAT, geolocation_lng)) AS average_longitude

    FROM [olist_stg].[bronze].[geolocation]

    GROUP BY geolocation_zip_code_prefix
)

SELECT
    s.geolocation_zip_code_prefix,

    b.average_latitude,
    s.geolocation_lat AS silver_latitude,

    b.average_longitude,
    s.geolocation_lng AS silver_longitude

FROM [olist_dwh].[silver].[geolocation] AS s

INNER JOIN bronze_averages AS b
    ON s.geolocation_zip_code_prefix = b.geolocation_zip_code_prefix

WHERE ABS(s.geolocation_lat - b.average_latitude) > 0.000001
   OR ABS(s.geolocation_lng - b.average_longitude) > 0.000001;


/*============================================================
  08. most frequent city validation
============================================================*/

-- bronze: identify the most frequent city for each zip code prefix

-- expected result: one most frequent city per zip code prefix

WITH city_frequency AS
(
    SELECT
        geolocation_zip_code_prefix,
        geolocation_city,
        COUNT(*) AS city_frequency,

        ROW_NUMBER() OVER
        (
            PARTITION BY geolocation_zip_code_prefix
            ORDER BY COUNT(*) DESC, geolocation_city
        ) AS row_number

    FROM [olist_stg].[bronze].[geolocation]

    WHERE geolocation_city IS NOT NULL

    GROUP BY
        geolocation_zip_code_prefix,
        geolocation_city
)

SELECT
    geolocation_zip_code_prefix,
    geolocation_city,
    city_frequency

FROM city_frequency

WHERE row_number = 1;


-- silver: inspect the selected city for each zip code prefix

SELECT
    geolocation_zip_code_prefix,
    geolocation_city

FROM [olist_dwh].[silver].[geolocation];


/*============================================================
  09. record reconciliation
============================================================*/

-- compare bronze and silver record counts

-- expected result: silver records should equal the number of unique bronze zip prefixes

SELECT
    (SELECT COUNT(*)
     FROM [olist_stg].[bronze].[geolocation]) AS bronze_records,

    (SELECT COUNT(DISTINCT geolocation_zip_code_prefix)
     FROM [olist_stg].[bronze].[geolocation]) AS bronze_unique_zip_prefixes,

    (SELECT COUNT(*)
     FROM [olist_dwh].[silver].[geolocation]) AS silver_records;


-- identify zip code prefixes missing from silver

-- expected result: zero records

SELECT DISTINCT
    b.geolocation_zip_code_prefix

FROM [olist_stg].[bronze].[geolocation] AS b

LEFT JOIN [olist_dwh].[silver].[geolocation] AS s
    ON b.geolocation_zip_code_prefix = s.geolocation_zip_code_prefix

WHERE s.geolocation_zip_code_prefix IS NULL;


-- identify unexpected zip code prefixes in silver

-- expected result: zero records

SELECT
    s.geolocation_zip_code_prefix

FROM [olist_dwh].[silver].[geolocation] AS s

LEFT JOIN [olist_stg].[bronze].[geolocation] AS b
    ON s.geolocation_zip_code_prefix = b.geolocation_zip_code_prefix

WHERE b.geolocation_zip_code_prefix IS NULL;


/*
  validation outcome:
  - original and aggregated geolocation records were profiled.
  - zip code prefix aggregation was investigated.
  - latitude and longitude averages were compared.
  - city frequency and selection were investigated.
  - duplicate zip code prefixes were checked.
  - bronze and silver record counts were reconciled.
  - missing and unexpected zip code prefixes were investigated.
  - final transformation results will be confirmed after reviewing the validation queries.
*/
