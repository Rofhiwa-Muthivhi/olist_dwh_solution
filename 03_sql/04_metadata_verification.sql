
USE olist_stg;


/*
i am checking if the three metadata columns have been
added to all my bronze tables with the correct data types.
this will help me confirm that my tables are ready for ingestion.
*/

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze'
  AND COLUMN_NAME IN (
      'dwh_load_ts',
      'dwh_source_file',
      'dwh_batch_id'
  )
ORDER BY
    TABLE_NAME,
    COLUMN_NAME;

