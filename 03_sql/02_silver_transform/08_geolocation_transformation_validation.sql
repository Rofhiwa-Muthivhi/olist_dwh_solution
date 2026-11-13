USE olist_dwh


-- i am visually inspecting five transformed geolocation records
-- expected result: transformation preview table
SELECT TOP 5
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state,
    dwh_load_ts
FROM olist_dwh.silver.geolocation
ORDER BY geolocation_zip_code_prefix;


-- i am comparing bronze and silver geolocation row counts
-- expected result: bronze records 1000163, silver 19015 records
SELECT
    'Bronze' AS layer,
    COUNT(*) AS total_records
FROM olist_stg.bronze.geolocation

UNION ALL

SELECT
    'Silver' AS layer,
    COUNT(*) AS total_records
FROM olist_dwh.silver.geolocation;


-- i am checking whether all geolocation zip prefixes contain five characters
-- expected result: 0
SELECT *
FROM olist_dwh.silver.geolocation
WHERE LEN(geolocation_zip_code_prefix) <> 5;


-- i am checking whether duplicate zip prefixes remain in silver
-- expected result: 0
SELECT
    geolocation_zip_code_prefix,
    COUNT(*) AS duplicate_count
FROM olist_dwh.silver.geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1;


-- i am checking for missing geolocation attributes
-- expected result: 0
SELECT *
FROM olist_dwh.silver.geolocation
WHERE geolocation_zip_code_prefix IS NULL
   OR geolocation_lat IS NULL
   OR geolocation_lng IS NULL
   OR geolocation_city IS NULL
   OR geolocation_state IS NULL;


-- i am checking the data types of latitude and longitude
-- expected result: decimal data type
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM olist_dwh.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'geolocation'
  AND COLUMN_NAME IN (
      'geolocation_lat',
      'geolocation_lng'
  );


-- i am recalculating average coordinates from bronze for comparison
-- expected result: 0
WITH bronze_averages AS
(
    SELECT
        geolocation_zip_code_prefix,
        CAST(AVG(TRY_CONVERT(DECIMAL(18,8), geolocation_lat)) AS DECIMAL(12,8))
            AS expected_lat,
        CAST(AVG(TRY_CONVERT(DECIMAL(18,8), geolocation_lng)) AS DECIMAL(12,8))
            AS expected_lng
    FROM olist_stg.bronze.geolocation
    GROUP BY geolocation_zip_code_prefix
)
SELECT
    b.geolocation_zip_code_prefix,
    b.expected_lat,
    s.geolocation_lat AS silver_lat,
    b.expected_lng,
    s.geolocation_lng AS silver_lng
FROM bronze_averages b
INNER JOIN olist_dwh.silver.geolocation s
    ON b.geolocation_zip_code_prefix = s.geolocation_zip_code_prefix
WHERE b.expected_lat <> s.geolocation_lat
   OR b.expected_lng <> s.geolocation_lng;


-- i am checking whether all bronze zip prefixes exist in silver
-- expected result: 0
SELECT DISTINCT
    b.geolocation_zip_code_prefix
FROM olist_stg.bronze.geolocation b
LEFT JOIN olist_dwh.silver.geolocation s
    ON b.geolocation_zip_code_prefix = s.geolocation_zip_code_prefix
WHERE s.geolocation_zip_code_prefix IS NULL;