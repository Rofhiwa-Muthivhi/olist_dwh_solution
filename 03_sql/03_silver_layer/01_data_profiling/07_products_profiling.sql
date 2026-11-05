USE [olist_stg];
GO

-- checking the total number of records for products

SELECT
    COUNT(*) AS total_products
FROM [olist_stg].[bronze].[products];


-- verifying that each product has a unique product id and identifying any repeated ids

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT product_id) AS unique_product_ids,
    COUNT(*) - COUNT(DISTINCT product_id) AS duplicate_product_ids
FROM [olist_stg].[bronze].[products];


-- checking for missing values in the product information

SELECT
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS null_category_name,
    SUM(CASE WHEN product_name_lenght IS NULL THEN 1 ELSE 0 END) AS null_product_name_length,
    SUM(CASE WHEN product_description_lenght IS NULL THEN 1 ELSE 0 END) AS null_description_length,
    SUM(CASE WHEN product_photos_qty IS NULL THEN 1 ELSE 0 END) AS null_photos_qty,
    SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS null_weight,
    SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS null_length,
    SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) AS null_height,
    SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) AS null_width
FROM [olist_stg].[bronze].[products];


-- analysing how products are distributed across the different categories

SELECT
    product_category_name,
    COUNT(*) AS total_products
FROM [olist_stg].[bronze].[products]
GROUP BY product_category_name
ORDER BY total_products DESC;


-- checking the minimum, maximum and average lengths of product names and descriptions

SELECT
    MIN(TRY_CONVERT(INT, product_name_lenght)) AS minimum_name_length,
    MAX(TRY_CONVERT(INT, product_name_lenght)) AS maximum_name_length,
    AVG(TRY_CONVERT(FLOAT, product_name_lenght)) AS average_name_length,

    MIN(TRY_CONVERT(INT, product_description_lenght)) AS minimum_description_length,
    MAX(TRY_CONVERT(INT, product_description_lenght)) AS maximum_description_length,
    AVG(TRY_CONVERT(FLOAT, product_description_lenght)) AS average_description_length
FROM [olist_stg].[bronze].[products];


-- checking the minimum, maximum and average product weights and dimensions

SELECT
    MIN(TRY_CONVERT(DECIMAL(10,2), product_weight_g)) AS minimum_weight,
    MAX(TRY_CONVERT(DECIMAL(10,2), product_weight_g)) AS maximum_weight,
    AVG(TRY_CONVERT(DECIMAL(10,2), product_weight_g)) AS average_weight,

    MIN(TRY_CONVERT(DECIMAL(10,2), product_length_cm)) AS minimum_length,
    MAX(TRY_CONVERT(DECIMAL(10,2), product_length_cm)) AS maximum_length,

    MIN(TRY_CONVERT(DECIMAL(10,2), product_height_cm)) AS minimum_height,
    MAX(TRY_CONVERT(DECIMAL(10,2), product_height_cm)) AS maximum_height,

    MIN(TRY_CONVERT(DECIMAL(10,2), product_width_cm)) AS minimum_width,
    MAX(TRY_CONVERT(DECIMAL(10,2), product_width_cm)) AS maximum_width

FROM [olist_stg].[bronze].[products];


-- identifying products with zero or negative weights and dimensions

SELECT
    product_id,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM [olist_stg].[bronze].[products]
WHERE
    TRY_CONVERT(DECIMAL(10,2), product_weight_g) <= 0
    OR TRY_CONVERT(DECIMAL(10,2), product_length_cm) <= 0
    OR TRY_CONVERT(DECIMAL(10,2), product_height_cm) <= 0
    OR TRY_CONVERT(DECIMAL(10,2), product_width_cm) <= 0;


-- identifying product measurements and attributes that cannot be converted into numerical data

SELECT
    SUM(CASE
        WHEN product_name_lenght IS NOT NULL
        AND TRY_CONVERT(INT, product_name_lenght) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_name_lengths,

    SUM(CASE
        WHEN product_description_lenght IS NOT NULL
        AND TRY_CONVERT(INT, product_description_lenght) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_description_lengths,

    SUM(CASE
        WHEN product_photos_qty IS NOT NULL
        AND TRY_CONVERT(INT, product_photos_qty) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_photo_quantities,

    SUM(CASE
        WHEN product_weight_g IS NOT NULL
        AND TRY_CONVERT(DECIMAL(10,2), product_weight_g) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_weights,

    SUM(CASE
        WHEN product_length_cm IS NOT NULL
        AND TRY_CONVERT(DECIMAL(10,2), product_length_cm) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_lengths,

    SUM(CASE
        WHEN product_height_cm IS NOT NULL
        AND TRY_CONVERT(DECIMAL(10,2), product_height_cm) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_heights,

    SUM(CASE
        WHEN product_width_cm IS NOT NULL
        AND TRY_CONVERT(DECIMAL(10,2), product_width_cm) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_widths

FROM [olist_stg].[bronze].[products];


-- identifying products that do not have an assigned category

SELECT
    product_id,
    product_category_name
FROM [olist_stg].[bronze].[products]
WHERE
    product_category_name IS NULL
    OR LTRIM(RTRIM(product_category_name)) = '';