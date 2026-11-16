
USE [olist_dwh];
GO

-- ============================================================
-- i am creating the prepared orders view
-- this view prepares and standardises order data from the bronze
-- layer before it is loaded into the silver orders table
-- ============================================================

CREATE OR ALTER VIEW [silver].[vw_orders_prepared]
AS
SELECT
    order_id,
    customer_id,

    -- standardise order status by removing unnecessary spaces and converting values to lowercase
    LOWER(LTRIM(RTRIM(order_status))) AS order_status,

    -- convert all order timestamps to datetime2 to ensure consistent date and time data types
    CAST(order_purchase_timestamp AS DATETIME2) AS order_purchase_timestamp,
    CAST(order_approved_at AS DATETIME2) AS order_approved_at,
    CAST(order_delivered_carrier_date AS DATETIME2) AS order_delivered_carrier_date,
    CAST(order_delivered_customer_date AS DATETIME2) AS order_delivered_customer_date,
    CAST(order_estimated_delivery_date AS DATETIME2) AS order_estimated_delivery_date,

    -- create a yes/no flag to identify orders that have been successfully delivered
    CASE
        WHEN LOWER(LTRIM(RTRIM(order_status))) = 'delivered'
        THEN 'Yes'
        ELSE 'No'
    END AS is_delivered,

    -- retain source metadata for data lineage and record tracking
    dwh_load_ts,
    dwh_source_file,
    dwh_batch_id

FROM [olist_stg].[bronze].[orders];
GO
