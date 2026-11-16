USE [olist_dwh];
GO

-- ============================================================
-- populate the date dimension
-- ============================================================
-- i am populating the date dimension with calendar dates
-- from 01 january 2016 to 31 december 2019.
-- the calendar dates are generated using a recursive cte,
-- with additional date attributes derived using sql functions.
-- ============================================================

SET DATEFIRST 1;

;WITH date_series AS
(
    -- generate the first calendar date
    SELECT CAST('20160101' AS DATE) AS full_date

    UNION ALL

    -- generate the next date until 31 december 2019
    SELECT DATEADD(DAY, 1, full_date)
    FROM date_series
    WHERE full_date < '20191231'
)

-- insert the generated dates and their calendar attributes
INSERT INTO [gold].[dim_date]
(
    date_key,
    full_date,
    day_of_month,
    day_of_week_number,
    day_name,
    week_of_year,
    month_number,
    month_name,
    quarter_number,
    year_number,
    is_weekend
)
SELECT
    CONVERT(INT, CONVERT(CHAR(8), ds.full_date, 112)) AS date_key,
    ds.full_date,
    DAY(ds.full_date) AS day_of_month,
    DATEPART(WEEKDAY, ds.full_date) AS day_of_week_number,
    DATENAME(WEEKDAY, ds.full_date) AS day_name,
    DATEPART(ISO_WEEK, ds.full_date) AS week_of_year,
    MONTH(ds.full_date) AS month_number,
    DATENAME(MONTH, ds.full_date) AS month_name,
    DATEPART(QUARTER, ds.full_date) AS quarter_number,
    YEAR(ds.full_date) AS year_number,

    CASE
        WHEN DATEPART(WEEKDAY, ds.full_date) IN (6, 7)
            THEN 1
        ELSE 0
    END AS is_weekend

FROM date_series AS ds
WHERE NOT EXISTS
(
    -- prevent inserting dates that already exist
    SELECT 1
    FROM [gold].[dim_date] AS d
    WHERE d.date_key = CONVERT(INT, CONVERT(CHAR(8), ds.full_date, 112))
)
OPTION (MAXRECURSION 0);
GO


-- ============================================================
-- insert the unknown date record
-- ============================================================
-- this record will be used when a date is missing or cannot
-- be matched during the loading of the fact tables.
-- using -1 ensures that fact records can still be linked to
-- the date dimension without leaving the foreign key empty.
-- ============================================================

IF NOT EXISTS
(
    SELECT 1
    FROM [gold].[dim_date]
    WHERE date_key = -1
)
BEGIN
    INSERT INTO [gold].[dim_date]
    (
        date_key,
        full_date,
        day_of_month,
        day_of_week_number,
        day_name,
        week_of_year,
        month_number,
        month_name,
        quarter_number,
        year_number,
        is_weekend
    )
    VALUES
    (
        -1,
        NULL,
        NULL,
        NULL,
        'Unknown',
        NULL,
        NULL,
        'Unknown',
        NULL,
        NULL,
        NULL
    );
END;
GO