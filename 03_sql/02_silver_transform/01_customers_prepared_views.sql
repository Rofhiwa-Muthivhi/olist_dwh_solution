USE olist_dwh;
GO

-- i am creating or updating the prepared customer view

CREATE OR ALTER VIEW silver.vw_customers_prepared
AS
SELECT
    customer_id,
    customer_unique_id,

    -- i am trimming and padding zip codes to five characters
    CAST(
        RIGHT(
            '00000' + LTRIM(RTRIM(customer_zip_code_prefix)),
            5
        )
        AS CHAR(5)
    ) AS customer_zip_code_prefix,

    -- i am removing unnecessary spaces from city and state
    LTRIM(RTRIM(customer_city)) AS customer_city,
    LTRIM(RTRIM(customer_state)) AS customer_state,

    -- i am retaining the source metadata for lineage
    dwh_load_ts,
    dwh_source_file,
    dwh_batch_id

FROM olist_stg.bronze.customers;
GO