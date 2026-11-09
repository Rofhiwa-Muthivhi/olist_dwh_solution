USE olist_dwh;
GO

-- i am creating a preparation view for the sellers dataset

CREATE OR ALTER VIEW silver.vw_sellers_prepared
AS
SELECT
    seller_id,

    -- i am trimming and padding zip prefixes to five characters
    CAST(
        RIGHT(
            '00000' + LTRIM(RTRIM(seller_zip_code_prefix)),
            5
        )
        AS CHAR(5)
    ) AS seller_zip_code_prefix,

    -- i am removing unnecessary spaces from city and state
    LTRIM(RTRIM(seller_city)) AS seller_city,
    LTRIM(RTRIM(seller_state)) AS seller_state,

    -- i am retaining source metadata
    dwh_load_ts,
    dwh_source_file,
    dwh_batch_id

FROM olist_stg.bronze.sellers;
GO