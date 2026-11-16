
USE [olist_dwh];
GO

-- ============================================================
-- i am creating a preparation view for geolocation before
-- loading it into the silver layer
-- this view aggregates geographical coordinates and identifies
-- the most frequently occurring city and state per zip prefix
-- ============================================================

CREATE OR ALTER VIEW [silver].[vw_geolocation_prepared]
AS

-- calculate the average latitude and longitude for each zip prefix
-- also retain the latest source load timestamp for data lineage
WITH coordinate_aggregation AS
(
    SELECT
        geolocation_zip_code_prefix,

        CAST(
            AVG(TRY_CONVERT(DECIMAL(18,10), geolocation_lat))
            AS DECIMAL(12,8)
        ) AS geolocation_lat,

        CAST(
            AVG(TRY_CONVERT(DECIMAL(18,10), geolocation_lng))
            AS DECIMAL(12,8)
        ) AS geolocation_lng,

        MAX(TRY_CONVERT(DATETIME2(7), dwh_load_ts)) AS dwh_load_ts

    FROM [olist_stg].[bronze].[geolocation]

    GROUP BY geolocation_zip_code_prefix
),

-- count how frequently each city occurs within a zip prefix
-- trim unnecessary spaces to ensure consistent city values during grouping
city_frequency AS
(
    SELECT
        geolocation_zip_code_prefix,
        LTRIM(RTRIM(geolocation_city)) AS geolocation_city,
        COUNT(*) AS city_count

    FROM [olist_stg].[bronze].[geolocation]

    GROUP BY
        geolocation_zip_code_prefix,
        LTRIM(RTRIM(geolocation_city))
),

-- rank cities according to their occurrence frequency within each zip prefix
-- use alphabetical order as a secondary sorting condition when frequencies are tied
city_ranking AS
(
    SELECT
        geolocation_zip_code_prefix,
        geolocation_city,

        ROW_NUMBER() OVER
        (
            PARTITION BY geolocation_zip_code_prefix
            ORDER BY city_count DESC, geolocation_city ASC
        ) AS city_rank

    FROM city_frequency
),

-- count how frequently each state occurs within a zip prefix
-- trim unnecessary spaces and convert state values to uppercase before grouping
state_frequency AS
(
    SELECT
        geolocation_zip_code_prefix,
        UPPER(LTRIM(RTRIM(geolocation_state))) AS geolocation_state,
        COUNT(*) AS state_count

    FROM [olist_stg].[bronze].[geolocation]

    GROUP BY
        geolocation_zip_code_prefix,
        UPPER(LTRIM(RTRIM(geolocation_state)))
),

-- rank states according to their occurrence frequency within each zip prefix
-- use alphabetical order as a secondary sorting condition when frequencies are tied
state_ranking AS
(
    SELECT
        geolocation_zip_code_prefix,
        geolocation_state,

        ROW_NUMBER() OVER
        (
            PARTITION BY geolocation_zip_code_prefix
            ORDER BY state_count DESC, geolocation_state ASC
        ) AS state_rank

    FROM state_frequency
)

-- combine the aggregated coordinates with the most frequently occurring city and state
-- retain only the highest-ranked city and state for each zip prefix
SELECT
    coordinates.geolocation_zip_code_prefix,
    coordinates.geolocation_lat,
    coordinates.geolocation_lng,
    cities.geolocation_city,
    states.geolocation_state,
    coordinates.dwh_load_ts

FROM coordinate_aggregation AS coordinates

INNER JOIN city_ranking AS cities
    ON coordinates.geolocation_zip_code_prefix =
       cities.geolocation_zip_code_prefix
    AND cities.city_rank = 1

INNER JOIN state_ranking AS states
    ON coordinates.geolocation_zip_code_prefix =
       states.geolocation_zip_code_prefix
    AND states.state_rank = 1;
GO
