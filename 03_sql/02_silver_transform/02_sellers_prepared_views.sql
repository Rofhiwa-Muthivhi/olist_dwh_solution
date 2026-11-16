
USE [olist_dwh];
GO

-- ============================================================
-- i am creating a preparation view for the sellers dataset
-- this view prepares seller data from the bronze layer before
-- it is loaded into the silver sellers table
-- ============================================================

CREATE OR ALTER VIEW [silver].[vw_sellers_prepared]
AS
SELECT
    seller_id,

    -- trim unnecessary spaces and pad zip prefixes with leading zeros to ensure five characters
    CAST(
        RIGHT(
            '00000' + LTRIM(RTRIM(seller_zip_code_prefix)),
            5
        )
        AS CHAR(5)
    ) AS seller_zip_code_prefix,

    -- remove unnecessary spaces from city and state values
    LTRIM(RTRIM(seller_city)) AS seller_city,
    LTRIM(RTRIM(seller_state)) AS seller_state,

    -- retain source metadata for data lineage and record tracking
    dwh_load_ts,
    dwh_source_file,
    dwh_batch_id

FROM [olist_stg].[bronze].[sellers];
GO
