USE olist_dwh;

-- i am visually inspecting five transformed review records
-- expected results: transformation preview table
SELECT TOP 5
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM olist_dwh.silver.order_reviews
ORDER BY review_answer_timestamp DESC;


-- i am comparing bronze and silver review row counts
-- expected results: bronze 99224, silver 98410
SELECT
    'Bronze' AS layer,
    COUNT(*) AS total_records
FROM olist_stg.bronze.order_reviews

UNION ALL

SELECT
    'Silver' AS layer,
    COUNT(*) AS total_records
FROM olist_dwh.silver.order_reviews;


-- i am checking the required data types in the silver reviews table
-- expected results: required data types
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM olist_dwh.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'order_reviews'
ORDER BY ORDINAL_POSITION;


-- i am checking whether duplicate review identifiers remain in silver
-- expected results: 0
SELECT
    review_id,
    COUNT(*) AS duplicate_count
FROM olist_dwh.silver.order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1;


-- i am checking whether review scores fall within the permitted range
-- expected results: 0
SELECT *
FROM olist_dwh.silver.order_reviews
WHERE review_score < 1
   OR review_score > 5
   OR review_score IS NULL;


-- i am checking for missing review and order identifiers
-- expected results: 0
SELECT *
FROM olist_dwh.silver.order_reviews
WHERE review_id IS NULL
   OR LTRIM(RTRIM(review_id)) = ''
   OR order_id IS NULL
   OR LTRIM(RTRIM(order_id)) = '';


-- i am identifying the latest bronze review record for each review id
-- expected results: 98410
WITH ranked_reviews AS
(
    SELECT
        review_id,
        order_id,
        review_answer_timestamp,
        ROW_NUMBER() OVER
        (
            PARTITION BY review_id
            ORDER BY review_answer_timestamp DESC, order_id ASC
        ) AS row_num
    FROM olist_stg.bronze.order_reviews
),
expected_reviews AS
(
    SELECT
        review_id,
        order_id,
        review_answer_timestamp
    FROM ranked_reviews
    WHERE row_num = 1
)
SELECT
    COUNT(*) AS expected_review_records
FROM expected_reviews;


-- i am checking whether silver retained the correct latest review records
-- expected results: 0
WITH ranked_reviews AS
(
    SELECT
        review_id,
        order_id,
        review_answer_timestamp,
        ROW_NUMBER() OVER
        (
            PARTITION BY review_id
            ORDER BY review_answer_timestamp DESC, order_id ASC
        ) AS row_num
    FROM olist_stg.bronze.order_reviews
),
expected_reviews AS
(
    SELECT
        review_id,
        order_id,
        review_answer_timestamp
    FROM ranked_reviews
    WHERE row_num = 1
)
SELECT
    e.review_id,
    e.order_id AS expected_order_id,
    s.order_id AS silver_order_id,
    e.review_answer_timestamp AS expected_timestamp,
    s.review_answer_timestamp AS silver_timestamp
FROM expected_reviews e
LEFT JOIN olist_dwh.silver.order_reviews s
    ON e.review_id = s.review_id
WHERE s.review_id IS NULL
   OR e.order_id <> s.order_id
   OR e.review_answer_timestamp <> s.review_answer_timestamp;