USE olist_dwh;

-- i am visually inspecting the first five transformed seller records
-- expected results: a visual table with transformation rules applied(preview)
SELECT TOP 5 *
FROM olist_dwh.silver.sellers
ORDER BY seller_id;


-- i am comparing the bronze and silver row counts
-- expected results: 3095 recors for bothe bronze and silver tables
SELECT
    'Bronze' AS layer,
    COUNT(*) AS total_records
FROM olist_stg.bronze.sellers

UNION ALL

SELECT
    'Silver' AS layer,
    COUNT(*) AS total_records
FROM olist_dwh.silver.sellers;


-- i am checking whether seller cities have leading or trailing spaces
-- expected results: 0
SELECT *
FROM olist_dwh.silver.sellers
WHERE seller_city <> LTRIM(RTRIM(seller_city));


-- i am checking whether seller states are uppercase
-- expected results: all seller_state must be uppercase and give results if not uppercase
SELECT *
FROM olist_dwh.silver.sellers
WHERE seller_state <> UPPER(seller_state);


-- i am checking for duplicate seller identifiers
-- expected results: no records of duplicate seller_id
SELECT
    seller_id,
    COUNT(*) AS duplicate_count
FROM olist_dwh.silver.sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;


-- i am checking for missing seller identifiers
-- expected results: no missing seller identifiers
SELECT *
FROM olist_dwh.silver.sellers
WHERE seller_id IS NULL
   OR LTRIM(RTRIM(seller_id)) = '';


-- i am checking for missing seller location information
-- expected results:  no missing seller location information
SELECT *
FROM olist_dwh.silver.sellers
WHERE seller_city IS NULL
   OR seller_state IS NULL
   OR seller_zip_code_prefix IS NULL;