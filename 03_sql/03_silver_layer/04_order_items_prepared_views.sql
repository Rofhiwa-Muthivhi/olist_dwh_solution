USE olist_dwh;
GO

-- i am creating a preparation view for the order items data before loading it into the silver layer
CREATE OR ALTER VIEW silver.vw_order_items_prepared
AS
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,

    -- i am converting price and freight_value to DECIMAL(10,2) to ensure consistent monetary precision
    CAST(price AS DECIMAL(10,2)) AS price,
    CAST(freight_value AS DECIMAL(10,2)) AS freight_value,

    -- i am preserving the ETL metadata for data lineage and auditing
    dwh_load_ts,
    dwh_source_file,
    dwh_batch_id

-- i am retrieving the original records from the bronze layer without modifying the source data
FROM olist_stg.bronze.order_items;