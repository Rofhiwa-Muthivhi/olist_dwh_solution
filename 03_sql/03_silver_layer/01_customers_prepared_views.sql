USE olist_dwh;

CREATE OR ALTER VIEW silver.vw_customers_prepared
AS
SELECT
    customer_id,
    customer_unique_id,

    -- i am trimming and padding the zip prefix to 5 characters
    RIGHT('00000' + LTRIM(RTRIM(customer_zip_code_prefix)), 5)
        AS customer_zip_code_prefix,

    -- i am removing unwanted spaces from the city and state
    LTRIM(RTRIM(customer_city)) AS customer_city,
    LTRIM(RTRIM(customer_state)) AS customer_state,

    dwh_load_ts,
    dwh_source_file,
    dwh_batch_id

FROM [olist_stg].[bronze].[customers];


-- i am checking the cleaned customer records
SELECT TOP (20)
    customer_id,
    customer_city,
    customer_state,
    customer_zip_code_prefix
FROM silver.vw_customers_prepared;


-- i am checking whether all zip prefixes contain 5 characters
SELECT
    LEN(customer_zip_code_prefix) AS zip_length,
    COUNT(*) AS total_records
FROM silver.vw_customers_prepared
GROUP BY LEN(customer_zip_code_prefix);


-- i am checking for unwanted spaces in city and state
SELECT COUNT(*) AS records_with_extra_spaces
FROM silver.vw_customers_prepared
WHERE customer_city <> LTRIM(RTRIM(customer_city))
   OR customer_state <> LTRIM(RTRIM(customer_state));


-- i am checking for zip prefixes longer than 5 characters
SELECT COUNT(*) AS zip_prefixes_over_5
FROM olist_stg.bronze.customers
WHERE LEN(LTRIM(RTRIM(customer_zip_code_prefix))) > 5;