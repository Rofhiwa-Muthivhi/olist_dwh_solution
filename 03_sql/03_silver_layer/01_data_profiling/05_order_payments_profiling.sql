USE [olist_stg];
GO

-- checking the total number of records for order payments

SELECT
    COUNT(*) AS total_payment_records
FROM [olist_stg].[bronze].[order_payments];


-- checking the number of columns in the order payments table

SELECT COUNT(*) AS total_columns
FROM [olist_stg].[INFORMATION_SCHEMA].[COLUMNS]
WHERE TABLE_SCHEMA = 'bronze'
AND TABLE_NAME = 'order_payments';

-- verifying whether each payment record has a unique order id and payment sequence combination

SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS total_records
FROM [olist_stg].[bronze].[order_payments]
GROUP BY
    order_id,
    payment_sequential
HAVING COUNT(*) > 1
ORDER BY total_records DESC;


-- checking for missing values in the payment information

SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN payment_sequential IS NULL THEN 1 ELSE 0 END) AS null_payment_sequential,
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS null_payment_type,
    SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END) AS null_payment_installments,
    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS null_payment_value
FROM [olist_stg].[bronze].[order_payments];


-- analysing the different payment methods used by customers and how frequently they occur

SELECT
    payment_type,
    COUNT(*) AS total_payment_records
FROM [olist_stg].[bronze].[order_payments]
GROUP BY payment_type
ORDER BY total_payment_records DESC;


-- identifying payment types with inconsistent casing or unwanted spaces

SELECT DISTINCT
    payment_type
FROM [olist_stg].[bronze].[order_payments]
WHERE
    payment_type <> LTRIM(RTRIM(payment_type))
    OR payment_type <> LOWER(payment_type)
ORDER BY payment_type;


-- analysing how frequently customers use different payment instalment options

SELECT
    TRY_CONVERT(INT, payment_installments) AS payment_installments,
    COUNT(*) AS total_payment_records
FROM [olist_stg].[bronze].[order_payments]
GROUP BY TRY_CONVERT(INT, payment_installments)
ORDER BY payment_installments;


-- checking the minimum, maximum and average payment values

SELECT
    MIN(TRY_CONVERT(DECIMAL(10,2), payment_value)) AS minimum_payment,
    MAX(TRY_CONVERT(DECIMAL(10,2), payment_value)) AS maximum_payment,
    AVG(TRY_CONVERT(DECIMAL(10,2), payment_value)) AS average_payment
FROM [olist_stg].[bronze].[order_payments];


-- identifying payment records with zero or negative payment values

SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_value
FROM [olist_stg].[bronze].[order_payments]
WHERE
    TRY_CONVERT(DECIMAL(10,2), payment_value) <= 0;


-- identifying payment values and instalments that cannot be converted into numerical data

SELECT
    SUM(CASE
        WHEN payment_installments IS NOT NULL
        AND TRY_CONVERT(INT, payment_installments) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_installments,

    SUM(CASE
        WHEN payment_value IS NOT NULL
        AND TRY_CONVERT(DECIMAL(10,2), payment_value) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_payment_values

FROM [olist_stg].[bronze].[order_payments];


USE [olist_stg];
GO

-- analysing how many orders have one or multiple payment records

SELECT
    total_payment_records,
    COUNT(*) AS total_orders
FROM
(
    SELECT
        order_id,
        COUNT(*) AS total_payment_records
    FROM [olist_stg].[bronze].[order_payments]
    GROUP BY order_id
) AS payment_summary
GROUP BY total_payment_records
ORDER BY total_payment_records;

