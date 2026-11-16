
USE [olist_dwh];
GO

-- ============================================================
-- i am creating a preparation view for order reviews before
-- loading them into the silver layer
-- this view prepares review records, removes duplicates and
-- standardises data types before loading into the silver table
-- ============================================================

CREATE OR ALTER VIEW [silver].[vw_order_reviews_prepared]
AS

-- rank review records to identify duplicates and retain only
-- the latest record for each review_id based on the review
-- answer timestamp, using order_id as a secondary sort column
WITH ranked_reviews AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY review_id
            ORDER BY
                review_answer_timestamp DESC,
                order_id ASC
        ) AS row_num
    FROM [olist_stg].[bronze].[order_reviews]
)

SELECT
    review_id,
    order_id,

    -- convert review_score to tinyint to ensure a consistent data type
    CAST(review_score AS TINYINT) AS review_score,

    -- preserve customer comments as nvarchar(max) to prevent text truncation
    CAST(review_comment_title AS NVARCHAR(MAX)) AS review_comment_title,
    CAST(review_comment_message AS NVARCHAR(MAX)) AS review_comment_message,

    -- convert review timestamps to datetime2 for consistent date and time handling
    CAST(review_creation_date AS DATETIME2) AS review_creation_date,
    CAST(review_answer_timestamp AS DATETIME2) AS review_answer_timestamp,

    -- preserve etl metadata for data lineage and auditing
    dwh_load_ts,
    dwh_source_file,
    dwh_batch_id

FROM ranked_reviews
WHERE row_num = 1;
