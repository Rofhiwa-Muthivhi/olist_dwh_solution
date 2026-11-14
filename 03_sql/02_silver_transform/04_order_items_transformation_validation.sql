
/*
============================================================
  olist data warehouse
  order items validation

  source: [olist_stg].[bronze].[order_items]
  target: [olist_dwh].[silver].[order_items]

  objective:
  compare bronze and silver data to validate the
  transformations implemented according to the
  instructor's requirements.

  required transformations:
  cast price and freight_value to decimal(10,2),
  derive total_item_value
============================================================
*/


/*============================================================
  01. record inspection
============================================================*/

-- bronze: inspect original order item records

SELECT TOP 20
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
FROM [olist_stg].[bronze].[order_items];


-- silver: inspect transformed order item records

SELECT TOP 20
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value,
    total_item_value
FROM [olist_dwh].[silver].[order_items];


/*============================================================
  02. dataset profiling
============================================================*/

-- bronze: profile record counts, uniqueness and null values

SELECT
    COUNT(*) AS total_records,

    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN order_item_id IS NULL THEN 1 ELSE 0 END) AS null_order_item_id,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
    SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) AS null_shipping_limit_date,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS null_freight_value

FROM [olist_stg].[bronze].[order_items];


-- silver: profile transformed records and compare data completeness

SELECT
    COUNT(*) AS total_records,

    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN order_item_id IS NULL THEN 1 ELSE 0 END) AS null_order_item_id,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
    SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) AS null_shipping_limit_date,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS null_freight_value,
    SUM(CASE WHEN total_item_value IS NULL THEN 1 ELSE 0 END) AS null_total_item_value

FROM [olist_dwh].[silver].[order_items];


/*============================================================
  03. numerical data type profiling
============================================================*/

-- bronze: inspect original numerical column data types

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE

FROM [olist_stg].INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'bronze'
  AND TABLE_NAME = 'order_items'
  AND COLUMN_NAME IN ('price', 'freight_value');


-- silver: inspect transformed numerical column data types

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE

FROM [olist_dwh].INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'order_items'
  AND COLUMN_NAME IN ('price', 'freight_value', 'total_item_value');


/*============================================================
  04. price standardisation
============================================================*/

-- bronze: examine original price distribution

SELECT
    MIN(TRY_CONVERT(DECIMAL(10,2), price)) AS minimum_price,
    MAX(TRY_CONVERT(DECIMAL(10,2), price)) AS maximum_price,
    AVG(TRY_CONVERT(DECIMAL(10,2), price)) AS average_price

FROM [olist_stg].[bronze].[order_items];


-- silver: examine transformed price distribution

SELECT
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price,
    AVG(price) AS average_price

FROM [olist_dwh].[silver].[order_items];


-- silver: identify records containing invalid price values

-- expected result: zero records

SELECT
    COUNT(*) AS failed_records

FROM [olist_dwh].[silver].[order_items]

WHERE price IS NULL;


/*============================================================
  05. freight value standardisation
============================================================*/

-- bronze: examine original freight value distribution

SELECT
    MIN(TRY_CONVERT(DECIMAL(10,2), freight_value)) AS minimum_freight_value,
    MAX(TRY_CONVERT(DECIMAL(10,2), freight_value)) AS maximum_freight_value,
    AVG(TRY_CONVERT(DECIMAL(10,2), freight_value)) AS average_freight_value

FROM [olist_stg].[bronze].[order_items];


-- silver: examine transformed freight value distribution

SELECT
    MIN(freight_value) AS minimum_freight_value,
    MAX(freight_value) AS maximum_freight_value,
    AVG(freight_value) AS average_freight_value

FROM [olist_dwh].[silver].[order_items];


-- silver: identify records containing invalid freight values

-- expected result: zero records

SELECT
    COUNT(*) AS failed_records

FROM [olist_dwh].[silver].[order_items]

WHERE freight_value IS NULL;


/*============================================================
  06. total item value validation
============================================================*/

-- silver: examine total item value distribution

SELECT
    MIN(total_item_value) AS minimum_total_item_value,
    MAX(total_item_value) AS maximum_total_item_value,
    AVG(total_item_value) AS average_total_item_value

FROM [olist_dwh].[silver].[order_items];


-- silver: validate total_item_value calculation

-- expected result: zero failed records

SELECT
    COUNT(*) AS failed_records

FROM [olist_dwh].[silver].[order_items]

WHERE total_item_value <> price + freight_value
   OR total_item_value IS NULL
   OR price IS NULL
   OR freight_value IS NULL;


-- silver: inspect individual item value calculations

SELECT TOP 20
    order_id,
    order_item_id,
    price,
    freight_value,
    total_item_value,
    price + freight_value AS expected_total_item_value

FROM [olist_dwh].[silver].[order_items]

ORDER BY order_id, order_item_id;


/*============================================================
  07. transformation validation
============================================================*/

-- silver: identify numerical columns that are not decimal(10,2)

-- expected result: zero records

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE

FROM [olist_dwh].INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'order_items'
  AND COLUMN_NAME IN ('price', 'freight_value')
  AND (
        DATA_TYPE <> 'decimal'
        OR NUMERIC_PRECISION <> 10
        OR NUMERIC_SCALE <> 2
      );


-- silver: validate total_item_value data type

-- expected result: decimal(10,2)

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE

FROM [olist_dwh].INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'order_items'
  AND COLUMN_NAME = 'total_item_value';


/*============================================================
  08. record reconciliation
============================================================*/

-- compare bronze and silver record counts

-- expected result: matching record counts

SELECT
    (SELECT COUNT(*)
     FROM [olist_stg].[bronze].[order_items]) AS bronze_records,

    (SELECT COUNT(*)
     FROM [olist_dwh].[silver].[order_items]) AS silver_records;


-- identify order item records missing from silver

-- expected result: zero records

SELECT
    b.order_id,
    b.order_item_id

FROM [olist_stg].[bronze].[order_items] AS b

LEFT JOIN [olist_dwh].[silver].[order_items] AS s
    ON b.order_id = s.order_id
    AND b.order_item_id = s.order_item_id

WHERE s.order_id IS NULL;


-- identify unexpected order item records in silver

-- expected result: zero records

SELECT
    s.order_id,
    s.order_item_id

FROM [olist_dwh].[silver].[order_items] AS s

LEFT JOIN [olist_stg].[bronze].[order_items] AS b
    ON s.order_id = b.order_id
    AND s.order_item_id = b.order_item_id

WHERE b.order_id IS NULL;


-- identify duplicate order item records in silver

-- expected result: zero records

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[order_items]

GROUP BY
    order_id,
    order_item_id

HAVING COUNT(*) > 1;


/*
  validation outcome:
  - the original and transformed order item records were profiled.
  - price and freight_value data types were investigated.
  - total_item_value was checked against the expected calculation.
  - bronze and silver record counts were compared.
  - missing, unexpected and duplicate order item records were investigated.
  - final transformation results will be confirmed after reviewing the validation queries.
*/
