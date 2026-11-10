USE olist_dwh;
GO

-- i am creating a preparation view for products before loading them into the silver layer
CREATE OR ALTER VIEW silver.vw_products_prepared
AS

-- i am joining products to their English category translations
SELECT
    p.product_id,

    -- i am preserving the original Portuguese category
    p.product_category_name,

    -- i am replacing missing English translations with Unknown
    COALESCE(
        NULLIF(LTRIM(RTRIM(t.column2)), ''),
        'Unknown'
    ) AS product_category_name_english,

    -- i am correcting the misspelt product column names
    p.product_name_lenght AS product_name_length,
    p.product_description_lenght AS product_description_length,

    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,

    -- i am preserving ETL metadata for lineage and auditing
    p.dwh_load_ts,
    p.dwh_source_file,
    p.dwh_batch_id

FROM olist_stg.bronze.products AS p

LEFT JOIN olist_stg.bronze.product_category_name_translation AS t
    ON p.product_category_name = t.column1;