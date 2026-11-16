
USE [olist_stg];


-- check if the etl schema and load log table exist in the database
-- return the schema name and table name to confirm that the load log table was created successfully
SELECT
    s.name AS schema_name,
    t.name AS table_name
FROM sys.tables t
INNER JOIN sys.schemas s
    ON t.schema_id = s.schema_id
WHERE s.name = 'etl'
  AND t.name = 'load_log';

