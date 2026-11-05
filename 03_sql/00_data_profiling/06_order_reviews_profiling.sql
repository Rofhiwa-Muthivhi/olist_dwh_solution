USE [olist_stg];
GO

-- checking the total number of records for order reviews

SELECT
    COUNT(*) AS total_review_records
FROM [olist_stg].[bronze].[order_reviews];


-- checking the number of columns in the order reviews table

SELECT COUNT(*) AS total_columns
FROM [olist_stg].[INFORMATION_SCHEMA].[COLUMNS]
WHERE TABLE_SCHEMA = 'bronze'
AND TABLE_NAME = 'order_reviews';

-- checking whether review ids appear more than once in the dataset

SELECT
    review_id,
    COUNT(*) AS total_records
FROM [olist_stg].[bronze].[order_reviews]
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY total_records DESC;


-- checking for missing values in the customer review information

SELECT
    SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END) AS null_review_id,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS null_review_score,
    SUM(CASE WHEN review_comment_title IS NULL THEN 1 ELSE 0 END) AS null_comment_title,
    SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END) AS null_comment_message,
    SUM(CASE WHEN review_creation_date IS NULL THEN 1 ELSE 0 END) AS null_creation_date,
    SUM(CASE WHEN review_answer_timestamp IS NULL THEN 1 ELSE 0 END) AS null_answer_timestamp
FROM [olist_stg].[bronze].[order_reviews];


-- analysing how frequently customers give each review score

SELECT
    review_score,
    COUNT(*) AS total_reviews
FROM [olist_stg].[bronze].[order_reviews]
GROUP BY review_score
ORDER BY TRY_CONVERT(INT, review_score);


-- identifying review scores that fall outside the expected range of 1 to 5

SELECT
    review_id,
    order_id,
    review_score
FROM [olist_stg].[bronze].[order_reviews]
WHERE
    TRY_CONVERT(INT, review_score) NOT BETWEEN 1 AND 5
    OR TRY_CONVERT(INT, review_score) IS NULL;


    -- identifying review scores that fall outside the expected range of 1 to 5

SELECT
    review_id,
    order_id,
    review_score
FROM [olist_stg].[bronze].[order_reviews]
WHERE
    TRY_CONVERT(INT, review_score) NOT BETWEEN 1 AND 5
    OR TRY_CONVERT(INT, review_score) IS NULL;


-- analysing how many customer reviews contain written comments

SELECT
    COUNT(*) AS total_reviews,
    SUM(CASE
        WHEN review_comment_message IS NOT NULL
        AND LTRIM(RTRIM(review_comment_message)) <> ''
        THEN 1 ELSE 0
    END) AS reviews_with_comments,
    SUM(CASE
        WHEN review_comment_message IS NULL
        OR LTRIM(RTRIM(review_comment_message)) = ''
        THEN 1 ELSE 0
    END) AS reviews_without_comments
FROM [olist_stg].[bronze].[order_reviews];


-- checking the length of customer comments to understand the amount of written feedback

SELECT
    MIN(LEN(review_comment_message)) AS shortest_comment,
    MAX(LEN(review_comment_message)) AS longest_comment,
    AVG(CAST(LEN(review_comment_message) AS FLOAT)) AS average_comment_length
FROM [olist_stg].[bronze].[order_reviews]
WHERE
    review_comment_message IS NOT NULL
    AND LTRIM(RTRIM(review_comment_message)) <> '';


-- identifying the earliest and latest dates on which customers submitted reviews

SELECT
    MIN(TRY_CONVERT(DATETIME2, review_creation_date)) AS earliest_review_date,
    MAX(TRY_CONVERT(DATETIME2, review_creation_date)) AS latest_review_date
FROM [olist_stg].[bronze].[order_reviews];


-- identifying the earliest and latest dates on which review responses were recorded

SELECT
    MIN(TRY_CONVERT(DATETIME2, review_answer_timestamp)) AS earliest_response_date,
    MAX(TRY_CONVERT(DATETIME2, review_answer_timestamp)) AS latest_response_date
FROM [olist_stg].[bronze].[order_reviews];


-- identifying reviews where the response timestamp occurs before the review creation date

SELECT
    review_id,
    order_id,
    review_creation_date,
    review_answer_timestamp
FROM [olist_stg].[bronze].[order_reviews]
WHERE
    TRY_CONVERT(DATETIME2, review_answer_timestamp)
    < TRY_CONVERT(DATETIME2, review_creation_date);


-- identifying review scores and timestamps that cannot be converted into their expected data types

SELECT
    SUM(CASE
        WHEN review_score IS NOT NULL
        AND TRY_CONVERT(TINYINT, review_score) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_review_scores,

    SUM(CASE
        WHEN review_creation_date IS NOT NULL
        AND TRY_CONVERT(DATETIME2, review_creation_date) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_creation_dates,

    SUM(CASE
        WHEN review_answer_timestamp IS NOT NULL
        AND TRY_CONVERT(DATETIME2, review_answer_timestamp) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_answer_timestamps

FROM [olist_stg].[bronze].[order_reviews];