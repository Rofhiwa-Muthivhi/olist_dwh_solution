USE [olist_dwh];
GO

-- ============================================================
-- i am creating the date dimension table in the gold layer
-- this table will provide calendar attributes for analysing
-- sales, payments, reviews and delivery performance
-- ============================================================

IF OBJECT_ID('[gold].[dim_date]', 'U') IS NULL
BEGIN
    CREATE TABLE [gold].[dim_date]
    (
        date_key INT NOT NULL,
        full_date DATE NULL,
        day_of_month TINYINT NULL,
        day_of_week_number TINYINT NULL,
        day_name NVARCHAR(10) NULL,
        week_of_year TINYINT NULL,
        month_number TINYINT NULL,
        month_name NVARCHAR(10) NULL,
        quarter_number TINYINT NULL,
        year_number SMALLINT NULL,
        is_weekend BIT NULL,

        CONSTRAINT PK_dim_date
            PRIMARY KEY (date_key),

        CONSTRAINT UQ_dim_date_full_date
            UNIQUE (full_date)
    );
END;
GO
