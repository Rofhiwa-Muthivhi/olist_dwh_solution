
-- create master batch log table

USE [olist_dwh];
GO

IF OBJECT_ID('etl.batch_log', 'U') IS NULL
BEGIN
    CREATE TABLE etl.batch_log
    (
        batch_id INT NOT NULL,
        start_ts DATETIME2 NOT NULL
            CONSTRAINT DF_batch_log_start_ts
            DEFAULT SYSDATETIME(),

        end_ts DATETIME2 NULL,

        status NVARCHAR(20) NOT NULL,

        CONSTRAINT PK_batch_log
            PRIMARY KEY (batch_id)
    );
END;
GO
