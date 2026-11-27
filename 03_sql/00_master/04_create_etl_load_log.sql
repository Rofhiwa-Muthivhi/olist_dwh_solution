
-- create central etl load log table


USE [olist_dwh];
GO

IF OBJECT_ID('etl.load_log', 'U') IS NULL
BEGIN
    CREATE TABLE etl.load_log
    (
        load_log_id INT IDENTITY(1,1) NOT NULL,

        batch_id INT NOT NULL,

        package NVARCHAR(100) NOT NULL,

        table_name NVARCHAR(128) NOT NULL,

        rows_read INT NOT NULL DEFAULT 0,

        rows_written INT NOT NULL DEFAULT 0,

        rows_error INT NOT NULL DEFAULT 0,

        ts DATETIME2 NOT NULL
            DEFAULT SYSDATETIME(),

        CONSTRAINT PK_load_log
            PRIMARY KEY (load_log_id)
    );
END;
GO
