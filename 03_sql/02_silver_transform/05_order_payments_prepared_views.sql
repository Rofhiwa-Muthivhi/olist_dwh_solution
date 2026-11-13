USE olist_dwh;
GO

-- i am creating a preparation view for the order payments data before loading it into the silver layer
CREATE OR ALTER VIEW silver.vw_order_payments_prepared
AS
SELECT
    order_id,

    -- i am converting payment_sequential and payment_installments to INT
    CAST(payment_sequential AS INT) AS payment_sequential,

    -- i am standardising payment_type by replacing not_defined with Unknown
    CASE
        WHEN LOWER(LTRIM(RTRIM(payment_type))) = 'not_defined'
        THEN 'Unknown'
        ELSE LTRIM(RTRIM(payment_type))
    END AS payment_type,

    CAST(payment_installments AS INT) AS payment_installments,

    -- i am converting payment_value to DECIMAL(10,2) for consistent monetary precision
    CAST(payment_value AS DECIMAL(10,2)) AS payment_value,

    -- i am preserving the ETL metadata for data lineage and auditing
    dwh_load_ts,
    dwh_source_file,
    dwh_batch_id

-- i am retrieving the original records from the bronze layer without modifying the source data
FROM olist_stg.bronze.order_payments;