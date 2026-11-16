
USE [olist_stg];

-- create the etl schema if it does not already exist in the database
IF SCHEMA_ID('etl') IS NULL
BEGIN
    EXEC('CREATE SCHEMA etl');
END;


-- create the load log table if it does not already exist
-- this table is used to keep track of each etl batch load, including the source file, number of rows loaded, load status, and load timestamp
IF OBJECT_ID('etl.load_log', 'U') IS NULL
BEGIN
    CREATE TABLE etl.load_log
    (
        load_log_id INT IDENTITY(1,1) PRIMARY KEY,
        batch_id INT NOT NULL,
        source_file NVARCHAR(260) NOT NULL,
        rows_loaded INT NOT NULL,
        load_status NVARCHAR(20) NOT NULL,
        load_timestamp DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;





