
USE olist_dwh;
GO

-- i am creating a preparation view for order reviews before loading them into the silver layer
CREATE OR ALTER VIEW silver.vw_order_reviews_prepared
AS

-- i am ranking review records to retain only the latest record for each review_id
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
    FROM olist_stg.bronze.order_reviews
)

SELECT
    review_id,
    order_id,

    -- i am converting review_score to TINYINT
    CAST(review_score AS TINYINT) AS review_score,

    -- i am preserving customer comments as NVARCHAR(MAX) to prevent truncation
    CAST(review_comment_title AS NVARCHAR(MAX)) AS review_comment_title,
    CAST(review_comment_message AS NVARCHAR(MAX)) AS review_comment_message,

    -- i am converting review timestamps to DATETIME2
    CAST(review_creation_date AS DATETIME2) AS review_creation_date,
    CAST(review_answer_timestamp AS DATETIME2) AS review_answer_timestamp,

    -- i am preserving ETL metadata for data lineage and auditing
    dwh_load_ts,
    dwh_source_file,
    dwh_batch_id

FROM ranked_reviews
WHERE row_num = 1;

