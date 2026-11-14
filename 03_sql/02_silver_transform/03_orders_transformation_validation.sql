
/*
============================================================
  olist data warehouse
  order validation

  source: [olist_stg].[bronze].[orders]
  target: [olist_dwh].[silver].[orders]

  objective:
  compare bronze and silver data to validate the
  transformations implemented according to the
  instructor's requirements.

  required transformations:
  cast timestamps to datetime2,
  standardise order_status,
  create is_delivered flag
============================================================
*/


/*============================================================
  01. record inspection
============================================================*/

-- bronze: inspect original order records

SELECT TOP 20
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM [olist_stg].[bronze].[orders];


-- silver: inspect transformed order records

SELECT TOP 20
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    is_delivered
FROM [olist_dwh].[silver].[orders];


/*============================================================
  02. dataset profiling
============================================================*/

-- bronze: profile record counts, uniqueness and null values

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT order_id) AS unique_order_ids,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,

    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS null_order_status,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS null_purchase_timestamp,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS null_approved_at,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS null_carrier_date,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS null_delivered_date,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS null_estimated_delivery_date

FROM [olist_stg].[bronze].[orders];


-- silver: profile transformed records and compare data completeness

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT order_id) AS unique_order_ids,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,

    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS null_order_status,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS null_purchase_timestamp,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS null_approved_at,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS null_carrier_date,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS null_delivered_date,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS null_estimated_delivery_date,

    SUM(CASE WHEN is_delivered IS NULL THEN 1 ELSE 0 END) AS null_is_delivered

FROM [olist_dwh].[silver].[orders];


/*============================================================
  03. timestamp standardisation
============================================================*/

-- bronze: inspect original timestamp data types

SELECT
    COLUMN_NAME,
    DATA_TYPE

FROM [olist_stg].INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'bronze'
  AND TABLE_NAME = 'orders'
  AND COLUMN_NAME LIKE '%timestamp%'
   OR TABLE_NAME = 'orders'
  AND COLUMN_NAME LIKE '%date%';


-- silver: inspect transformed timestamp data types

SELECT
    COLUMN_NAME,
    DATA_TYPE

FROM [olist_dwh].INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'orders'
  AND COLUMN_NAME LIKE '%timestamp%'
   OR TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'orders'
  AND COLUMN_NAME LIKE '%date%';


/*============================================================
  04. order status standardisation
============================================================*/

-- bronze: examine original order status values

SELECT
    order_status,
    COUNT(*) AS occurrence_count

FROM [olist_stg].[bronze].[orders]

GROUP BY order_status

ORDER BY occurrence_count DESC;


-- silver: examine standardised order status values

SELECT
    order_status,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[orders]

GROUP BY order_status

ORDER BY occurrence_count DESC;


-- silver: identify order statuses that are not lowercase

-- expected result: zero failed records

SELECT
    COUNT(*) AS failed_records

FROM [olist_dwh].[silver].[orders]

WHERE order_status <> LOWER(order_status);


/*============================================================
  05. delivery flag validation
============================================================*/

-- silver: examine delivery flag distribution

SELECT
    is_delivered,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[orders]

GROUP BY is_delivered

ORDER BY is_delivered;


-- silver: validate delivery flag against order status

-- expected result: zero failed records

SELECT
    COUNT(*) AS failed_records

FROM [olist_dwh].[silver].[orders]

WHERE
    is_delivered <>
    CASE
        WHEN order_status = 'delivered' THEN 'Yes'
        ELSE 'No'
    END;


/*============================================================
  06. transformation validation
============================================================*/

-- silver: validate timestamp columns use datetime2

-- expected result: all applicable timestamp columns use datetime2

SELECT
    COLUMN_NAME,
    DATA_TYPE

FROM [olist_dwh].INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'orders'
  AND DATA_TYPE <> 'datetime2';


/*============================================================
  07. record reconciliation
============================================================*/

-- compare bronze and silver record counts

-- expected result: matching record counts

SELECT
    (SELECT COUNT(*)
     FROM [olist_stg].[bronze].[orders]) AS bronze_records,

    (SELECT COUNT(*)
     FROM [olist_dwh].[silver].[orders]) AS silver_records;


-- identify order records missing from silver

-- expected result: zero records

SELECT
    b.order_id

FROM [olist_stg].[bronze].[orders] AS b

LEFT JOIN [olist_dwh].[silver].[orders] AS s
    ON b.order_id = s.order_id

WHERE s.order_id IS NULL;


-- identify unexpected order records in silver

-- expected result: zero records

SELECT
    s.order_id

FROM [olist_dwh].[silver].[orders] AS s

LEFT JOIN [olist_stg].[bronze].[orders] AS b
    ON s.order_id = b.order_id

WHERE b.order_id IS NULL;


-- identify duplicate order ids in silver

-- expected result: zero records

SELECT
    order_id,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[orders]

GROUP BY order_id

HAVING COUNT(*) > 1;


/*
  validation outcome:
  - order records were profiled in both bronze and silver.
  - timestamp conversions were investigated.
  - order status standardisation was examined.
  - delivery flags were checked against the corresponding order status.
  - record reconciliation was performed to identify missing or unexpected orders.
  - final transformation results will be confirmed after reviewing the validation queries.
*/
