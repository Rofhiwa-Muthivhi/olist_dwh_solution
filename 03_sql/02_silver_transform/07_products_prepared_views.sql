USE olist_dwh;
GO

-- i am creating a preparation view for products before loading them into silver
CREATE OR ALTER VIEW silver.vw_products_prepared
AS

-- i am joining products to their English category translations
SELECT
    p.product_id,
    p.product_category_name,

    -- i am replacing missing English translations with Unknown
    COALESCE(
        NULLIF(LTRIM(RTRIM(t.column2)), ''),
        'Unknown'
    ) AS product_category_name_english,

    -- i am correcting misspelt column names and converting numeric attributes to integers
    TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(p.product_name_lenght)), '')) AS product_name_length,
    TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(p.product_description_lenght)), '')) AS product_description_length,
    TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(p.product_photos_qty)), '')) AS product_photos_qty,
    TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(p.product_weight_g)), '')) AS product_weight_g,

    -- i am converting product dimensions to decimal values
    TRY_CONVERT(DECIMAL(10,2), NULLIF(LTRIM(RTRIM(p.product_length_cm)), '')) AS product_length_cm,
    TRY_CONVERT(DECIMAL(10,2), NULLIF(LTRIM(RTRIM(p.product_height_cm)), '')) AS product_height_cm,
    TRY_CONVERT(DECIMAL(10,2), NULLIF(LTRIM(RTRIM(p.product_width_cm)), '')) AS product_width_cm,

    -- i am preserving ETL metadata for lineage and auditing
    p.dwh_load_ts,
    p.dwh_source_file,
    p.dwh_batch_id

FROM olist_stg.bronze.products AS p

LEFT JOIN olist_stg.bronze.product_category_name_translation AS t
    ON p.product_category_name = t.column1;
GO

-- i am refreshing the view metadata after updating its definition
EXEC sys.sp_refreshview N'silver.vw_products_prepared';
GO