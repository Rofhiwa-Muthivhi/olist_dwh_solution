USE [olist_stg];
GO

-- checking the total number of records for geolocation

SELECT
    COUNT(*) AS total_geolocation_records
FROM [olist_stg].[bronze].[geolocation];


-- comparing the total geolocation records against the unique zip code prefixes

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT geolocation_zip_code_prefix) AS unique_zip_prefixes
FROM [olist_stg].[bronze].[geolocation];


-- checking for missing values in the geographical information

SELECT
    SUM(CASE WHEN geolocation_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_zip_prefix,
    SUM(CASE WHEN geolocation_lat IS NULL THEN 1 ELSE 0 END) AS null_latitude,
    SUM(CASE WHEN geolocation_lng IS NULL THEN 1 ELSE 0 END) AS null_longitude,
    SUM(CASE WHEN geolocation_city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN geolocation_state IS NULL THEN 1 ELSE 0 END) AS null_state
FROM [olist_stg].[bronze].[geolocation];


-- identifying zip code prefixes that are associated with multiple geographical records

SELECT
    geolocation_zip_code_prefix,
    COUNT(*) AS total_records
FROM [olist_stg].[bronze].[geolocation]
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1
ORDER BY total_records DESC;


-- checking the minimum, maximum and average geographical coordinates

SELECT
    MIN(TRY_CONVERT(DECIMAL(12,8), geolocation_lat)) AS minimum_latitude,
    MAX(TRY_CONVERT(DECIMAL(12,8), geolocation_lat)) AS maximum_latitude,
    AVG(TRY_CONVERT(DECIMAL(12,8), geolocation_lat)) AS average_latitude,

    MIN(TRY_CONVERT(DECIMAL(12,8), geolocation_lng)) AS minimum_longitude,
    MAX(TRY_CONVERT(DECIMAL(12,8), geolocation_lng)) AS maximum_longitude,
    AVG(TRY_CONVERT(DECIMAL(12,8), geolocation_lng)) AS average_longitude

FROM [olist_stg].[bronze].[geolocation];


-- identifying geographical coordinates that fall outside the approximate boundaries of brazil

SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
FROM [olist_stg].[bronze].[geolocation]
WHERE
    TRY_CONVERT(DECIMAL(12,8), geolocation_lat) NOT BETWEEN -34 AND 6
    OR TRY_CONVERT(DECIMAL(12,8), geolocation_lng) NOT BETWEEN -74 AND -34;


-- analysing the geographical records across the different brazilian states

SELECT
    geolocation_state,
    COUNT(*) AS total_records
FROM [olist_stg].[bronze].[geolocation]
GROUP BY geolocation_state
ORDER BY total_records DESC;


-- analysing how geographical records are distributed across the different cities

SELECT
    geolocation_city,
    COUNT(*) AS total_records
FROM [olist_stg].[bronze].[geolocation]
GROUP BY geolocation_city
ORDER BY total_records DESC;


-- identifying zip code prefixes associated with more than one city

SELECT
    geolocation_zip_code_prefix,
    COUNT(DISTINCT geolocation_city) AS total_cities
FROM [olist_stg].[bronze].[geolocation]
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(DISTINCT geolocation_city) > 1
ORDER BY total_cities DESC;


-- identifying latitude and longitude values that cannot be converted into decimal numbers

SELECT
    SUM(CASE
        WHEN geolocation_lat IS NOT NULL
        AND TRY_CONVERT(DECIMAL(12,8), geolocation_lat) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_latitudes,

    SUM(CASE
        WHEN geolocation_lng IS NOT NULL
        AND TRY_CONVERT(DECIMAL(12,8), geolocation_lng) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_longitudes

FROM [olist_stg].[bronze].[geolocation];


-- analysing how many zip code prefixes have different numbers of geographical records

SELECT
    total_records,
    COUNT(*) AS total_zip_prefixes
FROM
(
    SELECT
        geolocation_zip_code_prefix,
        COUNT(*) AS total_records
    FROM [olist_stg].[bronze].[geolocation]
    GROUP BY geolocation_zip_code_prefix
) AS zip_summary
GROUP BY total_records
ORDER BY total_records;