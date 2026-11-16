
USE [olist_dwh];
GO

-- ============================================================
-- i am creating a preparation view for products before loading
-- them into the silver layer
-- this view prepares product attributes, corrects column names
-- and joins products to their English category translations
-- ============================================================

CREATE OR ALTER VIEW [silver].[vw_products_prepared]
AS

-- join products to their English category translations using the product category name
SELECT
    p.product_id,
    p.product_category_name,

    -- replace missing or empty English category translations with Unknown
    COALESCE(
        NULLIF(LTRIM(RTRIM(t.column2)), ''),
        'Unknown'
    ) AS product_category_name_english,

    -- correct misspelt column names and convert numeric product attributes to integers
    TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(p.product_name_lenght)), '')) AS product_name_length,
    TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(p.product_description_lenght)), '')) AS product_description_length,
    TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(p.product_photos_qty)), '')) AS product_photos_qty,
    TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(p.product_weight_g)), '')) AS product_weight_g,

    -- convert product dimensions to decimal(10,2) for consistent numeric precision
    TRY_CONVERT(DECIMAL(10,2), NULLIF(LTRIM(RTRIM(p.product_length_cm)), '')) AS product_length_cm,
    TRY_CONVERT(DECIMAL(10,2), NULLIF(LTRIM(RTRIM(p.product_height_cm)), '')) AS product_height_cm,
    TRY_CONVERT(DECIMAL(10,2), NULLIF(LTRIM(RTRIM(p.product_width_cm)), '')) AS product_width_cm,

    -- preserve etl metadata for data lineage and auditing
    p.dwh_load_ts,
    p.dwh_source_file,
    p.dwh_batch_id

FROM [olist_stg].[bronze].[products] AS p

LEFT JOIN [olist_stg].[bronze].[product_category_name_translation] AS t
    ON p.product_category_name = t.column1;
GO

-- refresh the view metadata after updating its definition to ensure sql server recognises the latest changes
EXEC sys.sp_refreshview N'silver.vw_products_prepared';
GO
