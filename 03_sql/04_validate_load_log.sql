USE [olist_stg];


-- check that the etl schema and load log table exist
SELECT
    s.name AS schema_name,
    t.name AS table_name
FROM sys.tables t
INNER JOIN sys.schemas s
    ON t.schema_id = s.schema_id
WHERE s.name = 'etl'
  AND t.name = 'load_log';
