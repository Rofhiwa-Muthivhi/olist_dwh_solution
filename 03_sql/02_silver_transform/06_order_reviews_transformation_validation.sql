
/*
============================================================
  olist data warehouse
  order reviews validation

  source: [olist_stg].[bronze].[order_reviews]
  target: [olist_dwh].[silver].[order_reviews]

  objective:
  compare bronze and silver data to validate the
  transformations implemented according to the
  instructor's requirements.

  required transformations:
  deduplicate on review_id,
  cast review_score to tinyint,
  preserve review comments as nvarchar(max)
============================================================
*/


/*============================================================
  01. record inspection
============================================================*/

-- bronze: inspect original order review records

SELECT TOP 20
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM [olist_stg].[bronze].[order_reviews];


-- silver: inspect transformed order review records

SELECT TOP 20
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM [olist_dwh].[silver].[order_reviews];


/*============================================================
  02. dataset profiling
============================================================*/

-- bronze: profile record counts, uniqueness and null values

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT review_id) AS unique_review_ids,
    COUNT(DISTINCT order_id) AS unique_order_ids,

    SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END) AS null_review_id,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS null_review_score,
    SUM(CASE WHEN review_comment_title IS NULL THEN 1 ELSE 0 END) AS null_comment_title,
    SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END) AS null_comment_message

FROM [olist_stg].[bronze].[order_reviews];


-- silver: profile transformed records and compare data completeness

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT review_id) AS unique_review_ids,
    COUNT(DISTINCT order_id) AS unique_order_ids,

    SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END) AS null_review_id,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS null_review_score,
    SUM(CASE WHEN review_comment_title IS NULL THEN 1 ELSE 0 END) AS null_comment_title,
    SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END) AS null_comment_message

FROM [olist_dwh].[silver].[order_reviews];


/*============================================================
  03. duplicate profiling
============================================================*/

-- bronze: identify review ids appearing more than once

-- these are the records targeted by deduplication

SELECT
    review_id,
    COUNT(*) AS occurrence_count

FROM [olist_stg].[bronze].[order_reviews]

GROUP BY review_id

HAVING COUNT(*) > 1

ORDER BY occurrence_count DESC;


-- bronze: calculate the total number of duplicate records

SELECT
    COUNT(*) AS duplicate_review_groups

FROM
(
    SELECT
        review_id

    FROM [olist_stg].[bronze].[order_reviews]

    GROUP BY review_id

    HAVING COUNT(*) > 1

) AS duplicate_reviews;


-- silver: identify review ids appearing more than once

-- expected result: zero records

SELECT
    review_id,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[order_reviews]

GROUP BY review_id

HAVING COUNT(*) > 1;


/*============================================================
  04. review score validation
============================================================*/

-- bronze: examine original review score distribution

SELECT
    review_score,
    COUNT(*) AS occurrence_count

FROM [olist_stg].[bronze].[order_reviews]

GROUP BY review_score

ORDER BY review_score;


-- silver: examine transformed review score distribution

SELECT
    review_score,
    COUNT(*) AS occurrence_count

FROM [olist_dwh].[silver].[order_reviews]

GROUP BY review_score

ORDER BY review_score;


-- silver: inspect review score data type

SELECT
    COLUMN_NAME,
    DATA_TYPE

FROM [olist_dwh].INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'order_reviews'
  AND COLUMN_NAME = 'review_score';


-- silver: identify review scores outside the expected range

-- expected result: zero records

SELECT
    COUNT(*) AS failed_records

FROM [olist_dwh].[silver].[order_reviews]

WHERE review_score NOT BETWEEN 1 AND 5
   OR review_score IS NULL;


/*============================================================
  05. review comment validation
============================================================*/

-- bronze: inspect original review comment lengths

SELECT
    MAX(LEN(review_comment_title)) AS maximum_title_length,
    MAX(LEN(review_comment_message)) AS maximum_message_length,

    MAX(DATALENGTH(review_comment_title)) AS maximum_title_bytes,
    MAX(DATALENGTH(review_comment_message)) AS maximum_message_bytes

FROM [olist_stg].[bronze].[order_reviews];


-- silver: inspect transformed review comment lengths

SELECT
    MAX(LEN(review_comment_title)) AS maximum_title_length,
    MAX(LEN(review_comment_message)) AS maximum_message_length,

    MAX(DATALENGTH(review_comment_title)) AS maximum_title_bytes,
    MAX(DATALENGTH(review_comment_message)) AS maximum_message_bytes

FROM [olist_dwh].[silver].[order_reviews];


-- silver: confirm review comments use nvarchar(max)

-- expected result: both columns use nvarchar with maximum length -1

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH

FROM [olist_dwh].INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'order_reviews'
  AND COLUMN_NAME IN ('review_comment_title', 'review_comment_message');


/*============================================================
  06. transformation validation
============================================================*/

-- silver: validate review score uses tinyint

-- expected result: zero failed records

SELECT
    COLUMN_NAME,
    DATA_TYPE

FROM [olist_dwh].INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'order_reviews'
  AND COLUMN_NAME = 'review_score'
  AND DATA_TYPE <> 'tinyint';


-- silver: validate review comment columns use nvarchar(max)

-- expected result: zero failed records

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH

FROM [olist_dwh].INFORMATION_SCHEMA.COLUMNS

WHERE TABLE_SCHEMA = 'silver'
  AND TABLE_NAME = 'order_reviews'
  AND COLUMN_NAME IN ('review_comment_title', 'review_comment_message')
  AND (
        DATA_TYPE <> 'nvarchar'
        OR CHARACTER_MAXIMUM_LENGTH <> -1
      );


/*============================================================
  07. record reconciliation
============================================================*/

-- compare bronze and silver record counts

-- silver may contain fewer records because duplicates are removed

SELECT
    (SELECT COUNT(*)
     FROM [olist_stg].[bronze].[order_reviews]) AS bronze_records,

    (SELECT COUNT(*)
     FROM [olist_dwh].[silver].[order_reviews]) AS silver_records,

    (SELECT COUNT(DISTINCT review_id)
     FROM [olist_stg].[bronze].[order_reviews]) AS bronze_unique_review_ids;


-- identify review ids missing from silver

-- expected result: zero records

SELECT DISTINCT
    b.review_id

FROM [olist_stg].[bronze].[order_reviews] AS b

LEFT JOIN [olist_dwh].[silver].[order_reviews] AS s
    ON b.review_id = s.review_id

WHERE s.review_id IS NULL;


-- identify unexpected review ids in silver

-- expected result: zero records

SELECT
    s.review_id

FROM [olist_dwh].[silver].[order_reviews] AS s

LEFT JOIN [olist_stg].[bronze].[order_reviews] AS b
    ON s.review_id = b.review_id

WHERE b.review_id IS NULL;


/*============================================================
  08. latest review record validation
============================================================*/

-- bronze: identify the latest record for each review id

-- this reflects the deduplication approach used in the preparation view

WITH ranked_reviews AS
(
    SELECT
        review_id,
        order_id,
        review_score,
        review_answer_timestamp,

        ROW_NUMBER() OVER
        (
            PARTITION BY review_id
            ORDER BY review_answer_timestamp DESC
        ) AS row_num

    FROM [olist_stg].[bronze].[order_reviews]
)

SELECT TOP 20
    review_id,
    order_id,
    review_score,
    review_answer_timestamp

FROM ranked_reviews

WHERE row_num = 1

ORDER BY review_answer_timestamp DESC;


/*
  validation outcome:
  - original and transformed review records were profiled.
  - duplicate review ids were investigated in bronze and silver.
  - review score conversion to tinyint was validated.
  - review comment columns were checked for nvarchar(max).
  - comment lengths were compared between bronze and silver.
  - deduplication results were examined.
  - missing and unexpected review ids were investigated.
  - final transformation results will be confirmed after reviewing the validation queries.
*/