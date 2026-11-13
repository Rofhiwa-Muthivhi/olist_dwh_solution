USE olist_dwh;
GO

-- i am creating a preparation view for product category translations
CREATE OR ALTER VIEW silver.vw_product_category_name_translation_prepared
AS

-- i am selecting and cleaning the original translations
WITH original_translations AS
(
    SELECT
        LTRIM(RTRIM(column1)) AS product_category_name,
        LTRIM(RTRIM(column2)) AS product_category_name_english,
        MAX(TRY_CONVERT(DATETIME2(7), dwh_load_ts)) AS dwh_load_ts
    FROM olist_stg.bronze.product_category_name_translation
    WHERE NULLIF(LTRIM(RTRIM(column1)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(column2)), '') IS NOT NULL
    GROUP BY
        LTRIM(RTRIM(column1)),
        LTRIM(RTRIM(column2))
),

-- i am adding the two missing category translations
missing_translations AS
(
    SELECT
        CAST('pc_gamer' AS NVARCHAR(255)) AS product_category_name,
        CAST('PC Gamer' AS NVARCHAR(255)) AS product_category_name_english,
        CAST(SYSDATETIME() AS DATETIME2(7)) AS dwh_load_ts

    UNION ALL

    SELECT
        CAST('portateis_cozinha_e_preparadores_de_alimentos' AS NVARCHAR(255)),
        CAST('Kitchen and Food Preparation Appliances' AS NVARCHAR(255)),
        CAST(SYSDATETIME() AS DATETIME2(7))
)

-- i am combining original and missing translations
SELECT
    product_category_name,
    product_category_name_english,
    dwh_load_ts
FROM original_translations

UNION ALL

SELECT
    missing.product_category_name,
    missing.product_category_name_english,
    missing.dwh_load_ts
FROM missing_translations AS missing
WHERE NOT EXISTS
(
    SELECT 1
    FROM original_translations AS original
    WHERE original.product_category_name = missing.product_category_name
);
GO