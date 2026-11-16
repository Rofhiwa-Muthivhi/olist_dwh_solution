
USE [olist_dwh];
GO

-- ============================================================
-- i am creating a preparation view for the order payments data
-- this view prepares and standardises payment records from the
-- bronze layer before loading them into the silver order payments table
-- ============================================================

CREATE OR ALTER VIEW [silver].[vw_order_payments_prepared]
AS
SELECT
    order_id,

    -- convert payment_sequential and payment_installments to int for consistent data types
    CAST(payment_sequential AS INT) AS payment_sequential,

    -- standardise payment_type by removing unnecessary spaces and replacing not_defined with Unknown
    CASE
        WHEN LOWER(LTRIM(RTRIM(payment_type))) = 'not_defined'
        THEN 'Unknown'
        ELSE LTRIM(RTRIM(payment_type))
    END AS payment_type,

    CAST(payment_installments AS INT) AS payment_installments,

    -- convert payment_value to decimal(10,2) to ensure consistent monetary precision
    CAST(payment_value AS DECIMAL(10,2)) AS payment_value,

    -- preserve etl metadata for data lineage and auditing
    dwh_load_ts,
    dwh_source_file,
    dwh_batch_id

-- retrieve the original records from the bronze layer without modifying the source data
FROM [olist_stg].[bronze].[order_payments];
