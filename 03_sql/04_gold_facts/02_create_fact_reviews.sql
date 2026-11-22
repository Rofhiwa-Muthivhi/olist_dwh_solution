USE [olist_dwh];
GO

-- =============================================
-- i am creating the fact_reviews table
-- =============================================

IF OBJECT_ID('gold.fact_reviews', 'U') IS NOT NULL
    DROP TABLE [gold].[fact_reviews];
GO

CREATE TABLE [gold].[fact_reviews]
(
    review_key BIGINT IDENTITY(1,1) NOT NULL,

    review_id VARCHAR(50) NOT NULL,
    order_id VARCHAR(50) NOT NULL,

    customer_key INT NOT NULL,
    date_key INT NOT NULL,

    review_score TINYINT NULL,

    review_comment_title NVARCHAR(MAX) NULL,
    review_comment_message NVARCHAR(MAX) NULL,

    review_creation_date DATETIME2 NULL,
    review_answer_timestamp DATETIME2 NULL,

    CONSTRAINT PK_fact_reviews
        PRIMARY KEY CLUSTERED (review_key),

    CONSTRAINT FK_fact_reviews_dim_customer
        FOREIGN KEY (customer_key)
        REFERENCES [gold].[dim_customer](customer_key),

    CONSTRAINT FK_fact_reviews_dim_date
        FOREIGN KEY (date_key)
        REFERENCES [gold].[dim_date](date_key)
);
GO