
/*
============================================================
  olist data warehouse
  order payments validation

  source: [olist_stg].[bronze].[order_payments]
  target: [olist_dwh].[silver].[order_payments]

  objective:
  compare bronze and silver data to validate the
  transformations implemented according to the
  instructor's requirements.

  required transformations:
  cast payment_sequential and payment_installments to int,
  cast payment_value to decimal(10,2),
  standardise payment_type (not_defined to Unknown)
============================================================
*/


/*============================================================
  01. record inspection
============================================================*/

-- bronze: inspect original order payment records

SELECT TOP 20
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM [olist_stg].[bronze].[order_payments];


-- silver: inspect transformed order payment records

SELECT TOP 20
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM [olist_dwh].[silver].[order_payments];


/*============================================================
  02. dataset profiling
============================================================*/

-- bronze: profile record counts, uniqueness and null values

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT order_id) AS unique_order_ids,

    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN payment_sequential IS NULL THEN 1 ELSE 0 END) AS null_payment_sequential,
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS null_payment_type,
    SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END) AS null_payment_installments,
    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS null_payment_value

FROM [olist_stg].[bronze].[order_payments];


-- silver: profile transformed records and compare data completeness

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT order_id) AS unique_order_ids,

    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN payment_sequential IS NULL THEN 1 ELSE 0 END) AS null_payment_sequential,
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS null_payment_type,
    SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END) AS null_payment_installments,
    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS null_payment_value

FROM [olist_dwh].[silver].[order_payments];


/*============================================================
  03. payment data type profiling
============================================================*/

-- bronze: inspect original payment column data types

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE

FROM [olist_stg].INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'bronze'
  AND TABLE_NAME = 'order_payments';


-- silver: inspect transformed payment column data types

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE

FROM [olist_dwh].INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'order_payments';


/*============================================================
  04. payment type standardisation
============================================================*/

-- bronze: examine original payment type values

SELECT
    payment_type,
    COUNT(*) AS occurrence_count

FROM [olist_stg].[bronze].[order_payments]

GROUP BY payment_type

ORDER BY occurrence_count DESC;


-- silver: examine standardised payment type values

SELECT
    payment_type,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[order_payments]

GROUP BY payment_type

ORDER BY occurrence_count DESC;


-- silver: identify records where not_defined remains

-- expected result: zero records

SELECT
    COUNT(*) AS failed_records

FROM [olist_dwh].[silver].[order_payments]

WHERE LOWER(LTRIM(RTRIM(payment_type))) = 'not_defined';


-- silver: confirm that unknown payment types are present

SELECT
    payment_type,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[order_payments]

WHERE payment_type = 'Unknown'

GROUP BY payment_type;


/*============================================================
  05. payment sequential validation
============================================================*/

-- bronze: examine original payment sequential distribution

SELECT
    payment_sequential,
    COUNT(*) AS occurrence_count

FROM [olist_stg].[bronze].[order_payments]

GROUP BY payment_sequential

ORDER BY payment_sequential;


-- silver: examine transformed payment sequential distribution

SELECT
    payment_sequential,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[order_payments]

GROUP BY payment_sequential

ORDER BY payment_sequential;


/*============================================================
  06. payment installments validation
============================================================*/

-- bronze: examine original payment installment distribution

SELECT
    payment_installments,
    COUNT(*) AS occurrence_count

FROM [olist_stg].[bronze].[order_payments]

GROUP BY payment_installments

ORDER BY payment_installments;


-- silver: examine transformed payment installment distribution

SELECT
    payment_installments,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[order_payments]

GROUP BY payment_installments

ORDER BY payment_installments;


/*============================================================
  07. payment value validation
============================================================*/

-- bronze: examine original payment value distribution

SELECT
    MIN(TRY_CONVERT(DECIMAL(10,2), payment_value)) AS minimum_payment_value,
    MAX(TRY_CONVERT(DECIMAL(10,2), payment_value)) AS maximum_payment_value,
    AVG(TRY_CONVERT(DECIMAL(10,2), payment_value)) AS average_payment_value

FROM [olist_stg].[bronze].[order_payments];


-- silver: examine transformed payment value distribution

SELECT
    MIN(payment_value) AS minimum_payment_value,
    MAX(payment_value) AS maximum_payment_value,
    AVG(payment_value) AS average_payment_value

FROM [olist_dwh].[silver].[order_payments];


/*============================================================
  08. transformation validation
============================================================*/

-- silver: identify payment columns that failed type conversion

-- expected result: zero records

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE

FROM [olist_dwh].INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'order_payments'

  AND (
        (COLUMN_NAME IN ('payment_sequential', 'payment_installments')
         AND DATA_TYPE <> 'int')

        OR

        (COLUMN_NAME = 'payment_value'
         AND (
                DATA_TYPE <> 'decimal'
                OR NUMERIC_PRECISION <> 10
                OR NUMERIC_SCALE <> 2
             ))
      );


-- validate that bronze not_defined values became Unknown in silver

-- expected result: zero failed records

SELECT
    COUNT(*) AS failed_records

FROM [olist_stg].[bronze].[order_payments] AS b

INNER JOIN [olist_dwh].[silver].[order_payments] AS s
    ON b.order_id = s.order_id
    AND TRY_CONVERT(INT, b.payment_sequential) = s.payment_sequential

WHERE LOWER(LTRIM(RTRIM(b.payment_type))) = 'not_defined'
  AND s.payment_type <> 'Unknown';


/*============================================================
  09. record reconciliation
============================================================*/

-- compare bronze and silver record counts

-- expected result: matching record counts

SELECT
    (SELECT COUNT(*)
     FROM [olist_stg].[bronze].[order_payments]) AS bronze_records,

    (SELECT COUNT(*)
     FROM [olist_dwh].[silver].[order_payments]) AS silver_records;


-- identify payment records missing from silver

-- expected result: zero records

SELECT
    b.order_id,
    b.payment_sequential

FROM [olist_stg].[bronze].[order_payments] AS b

LEFT JOIN [olist_dwh].[silver].[order_payments] AS s
    ON b.order_id = s.order_id
    AND TRY_CONVERT(INT, b.payment_sequential) = s.payment_sequential

WHERE s.order_id IS NULL;


-- identify unexpected payment records in silver

-- expected result: zero records

SELECT
    s.order_id,
    s.payment_sequential

FROM [olist_dwh].[silver].[order_payments] AS s

LEFT JOIN [olist_stg].[bronze].[order_payments] AS b
    ON s.order_id = b.order_id
    AND TRY_CONVERT(INT, b.payment_sequential) = s.payment_sequential

WHERE b.order_id IS NULL;


-- identify duplicate payment records in silver

-- expected result: zero records

SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[order_payments]

GROUP BY
    order_id,
    payment_sequential

HAVING COUNT(*) > 1;


/*
  validation outcome:
  - original and transformed payment records were profiled.
  - payment sequential and payment installments data types were investigated.
  - payment value precision and scale were validated.
  - not_defined payment types were checked for conversion to Unknown.
  - bronze and silver record counts were compared.
  - missing, unexpected and duplicate payment records were investigated.
  - final transformation results will be confirmed after reviewing the validation queries.
*/
