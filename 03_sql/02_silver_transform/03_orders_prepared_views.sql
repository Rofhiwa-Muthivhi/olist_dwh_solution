
USE olist_dwh;
GO

-- i am creating the prepared orders view

CREATE OR ALTER VIEW silver.vw_orders_prepared
AS
SELECT
    order_id,
    customer_id,

    -- i am standardising order status
    LOWER(LTRIM(RTRIM(order_status))) AS order_status,

    -- i am converting all order timestamps to datetime2
    CAST(order_purchase_timestamp AS DATETIME2) AS order_purchase_timestamp,
    CAST(order_approved_at AS DATETIME2) AS order_approved_at,
    CAST(order_delivered_carrier_date AS DATETIME2) AS order_delivered_carrier_date,
    CAST(order_delivered_customer_date AS DATETIME2) AS order_delivered_customer_date,
    CAST(order_estimated_delivery_date AS DATETIME2) AS order_estimated_delivery_date,

    -- i am creating a yes/no flag to identify delivered orders
    CASE
        WHEN LOWER(LTRIM(RTRIM(order_status))) = 'delivered'
        THEN 'Yes'
        ELSE 'No'
    END AS is_delivered,

    -- i am retaining metadata for data lineage
    dwh_load_ts,
    dwh_source_file,
    dwh_batch_id

FROM [olist_stg].[bronze].[orders];
GO
