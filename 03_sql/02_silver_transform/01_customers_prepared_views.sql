USE [olist_dwh];
GO

-- ============================================================
-- i am creating or updating the prepared customer view
-- this view prepares customer data from the bronze layer
-- before it is loaded into the silver customers table
-- ============================================================

CREATE OR ALTER VIEW [silver].[vw_customers_prepared]
AS
SELECT
    customer_id,
    customer_unique_id,

    -- trim unnecessary spaces and pad zip codes with leading zeros to ensure five characters
    CAST(
        RIGHT(
            '00000' + LTRIM(RTRIM(customer_zip_code_prefix)),
            5
        )
        AS CHAR(5)
    ) AS customer_zip_code_prefix,

    -- remove unnecessary spaces from city and state values
    LTRIM(RTRIM(customer_city)) AS customer_city,
    LTRIM(RTRIM(customer_state)) AS customer_state,

    -- retain source metadata for data lineage and record tracking
    dwh_load_ts,
    dwh_source_file,
    dwh_batch_id

FROM [olist_stg].[bronze].[customers];
GO
