
USE [olist_dwh];
GO

-- ============================================================
-- i am creating a preparation view for product category translations
-- this view cleans the original category translations and adds
-- the two missing category translations before loading them
-- into the silver layer
-- ============================================================

CREATE OR ALTER VIEW [silver].[vw_product_category_name_translation_prepared]
AS

-- select and clean the original category translations
-- remove unnecessary spaces and exclude records with missing category names or translations
-- retain the latest source load timestamp for each category translation
WITH original_translations AS
(
    SELECT
        LTRIM(RTRIM(column1)) AS product_category_name,
        LTRIM(RTRIM(column2)) AS product_category_name_english,
        MAX(TRY_CONVERT(DATETIME2(7), dwh_load_ts)) AS dwh_load_ts
    FROM [olist_stg].[bronze].[product_category_name_translation]
    WHERE NULLIF(LTRIM(RTRIM(column1)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(column2)), '') IS NOT NULL
    GROUP BY
        LTRIM(RTRIM(column1)),
        LTRIM(RTRIM(column2))
),

-- add the two missing category translations that are not available in the original dataset
-- assign the Portuguese category names their corresponding English translations
-- use the current system timestamp as the load timestamp for these manually added records
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

-- combine the original category translations with the two missing translations
-- use not exists to ensure that manually added categories are only included when they are not already present in the original translations
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
