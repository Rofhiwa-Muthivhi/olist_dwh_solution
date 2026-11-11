
USE olist_dwh;
GO

-- i am creating a preparation view for geolocation before loading into silver
CREATE OR ALTER VIEW silver.vw_geolocation_prepared
AS

-- i am calculating the average latitude and longitude per zip prefix
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

    FROM olist_stg.bronze.geolocation

    GROUP BY geolocation_zip_code_prefix
),

-- i am counting the frequency of each city per zip prefix
city_frequency AS
(
    SELECT
        geolocation_zip_code_prefix,
        LTRIM(RTRIM(geolocation_city)) AS geolocation_city,
        COUNT(*) AS city_count

    FROM olist_stg.bronze.geolocation

    GROUP BY
        geolocation_zip_code_prefix,
        LTRIM(RTRIM(geolocation_city))
),

-- i am ranking cities by frequency and using alphabetical order for ties
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

-- i am counting the frequency of each state per zip prefix
state_frequency AS
(
    SELECT
        geolocation_zip_code_prefix,
        UPPER(LTRIM(RTRIM(geolocation_state))) AS geolocation_state,
        COUNT(*) AS state_count

    FROM olist_stg.bronze.geolocation

    GROUP BY
        geolocation_zip_code_prefix,
        UPPER(LTRIM(RTRIM(geolocation_state)))
),

-- i am ranking states by frequency and using alphabetical order for ties
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

-- i am combining aggregated coordinates with the selected city and state
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
