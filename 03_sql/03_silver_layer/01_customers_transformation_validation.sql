USE olist_dwh;

-- i am visually inspecting the first five transformed customer records
SELECT TOP 5 *
FROM silver.customers;

-- i am checking whether customer text columns contain unwanted whitespace
-- expected result: 0
SELECT COUNT(*) AS records_with_whitespace
FROM silver.customers
WHERE customer_city <> LTRIM(RTRIM(customer_city))
   OR customer_state <> LTRIM(RTRIM(customer_state));


-- i am checking whether all customer states are uppercase
-- expected results: 0
SELECT COUNT(*) AS records_with_lowercase_states
FROM silver.customers
WHERE customer_state <> UPPER(customer_state);


-- i am checking whether all customer zip prefixes contain five characters
-- expected results: 0
SELECT COUNT(*) AS invalid_zip_prefixes
FROM silver.customers
WHERE LEN(customer_zip_code_prefix) <> 5;


-- i am inspecting customer city names after proper-case transformation
-- expected results: i want to see proper casing for each customer city name
SELECT TOP 30
    customer_city
FROM silver.customers
ORDER BY customer_city;