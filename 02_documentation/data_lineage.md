
## Bronze Data Lineage

### 1. Purpose

I created this document to show where my source data comes from and where it is stored in the Bronze layer.

The source data consists of nine CSV files. Each file is mapped to a corresponding table in the olist_stg database under the bronze schema.

### 2. Source-to-Bronze Mapping

| Source file                             | Destination table                                    |
| --------------------------------------- | ---------------------------------------------------- |
|  olist_customers_dataset.csv           |  olist_stg.bronze.customers                         |
|  olist_geolocation_dataset.csv         |  olist_stg.bronze.geolocation                       |
|  olist_order_items_dataset.csv         |  olist_stg.bronze.order_items                       |
|  olist_order_payments_dataset.csv      |  olist_stg.bronze.order_payments                    |
|  olist_order_reviews_dataset.csv       |  olist_stg.bronze.order_reviews                     |
|  olist_orders_dataset.csv              |  olist_stg.bronze.orders                            |
|  olist_products_dataset.csv            |  olist_stg.bronze.products                          |
|  olist_sellers_dataset.csv             |  olist_stg.bronze.sellers                           |
|  product_category_name_translation.csv |  olist_stg.bronze.product_category_name_translation |


### 3. Data Flow

The nine source CSV files are ingested using SSIS and loaded into their corresponding Bronze tables.

The ingestion is managed through the 01_bronze_load.dtsx package, which handles database preparation, truncation, data loading and ETL logging.

Each CSV file has its own Data Flow Task, making the process easier to manage and troubleshoot.

The Bronze tables retain the original source columns and include additional metadata columns to support data traceability.

### 4. Ingestion Metadata

Three metadata columns are added to every Bronze table through the Derived Column transformation.

| Column            | Purpose                                       | Value generated from |
| ----------------- | --------------------------------------------- | -------------------- |
| dwh_load_ts    | Records when the data was loaded.             | GETDATE()          |
| dwh_source_file | Identifies the original source file.          | Fixed CSV filename   |
| dwh_batch_id    | Identifies the batch that loaded the records. | User::BatchId     |

The Batch ID is generated automatically using a SQL Server Sequence before the data loading process begins.

The generated ID is stored in the SSIS package variable User::BatchId and shared across all nine datasets during that package execution.

This allows me to identify which records belong to the same ingestion batch.

### 5. ETL Logging

I created an ETL logging table called etl.load_log in the olist_stg database.

The table captures the results of each dataset load.

| Column           | Purpose                                 |
| ---------------- | --------------------------------------- |
| load_log_id    | Identifies each log record.             |
| batch_id       | Identifies the ingestion batch.         |
| source_file    | Records the source CSV filename.        |
| rows_loaded     | Records the load status.                |
| load_timestamp | Records when the log entry was created. |

Each Data Flow Task has a corresponding Execute SQL Task that records its loading results.

The Row Count transformation captures the number of incoming records, while parameter mapping passes the row count and Batch ID from SSIS variables into the logging table.

Each logging task is connected to its Data Flow Task using a Success precedence constraint. This ensures that the logging task runs after its corresponding Data Flow completes successfully.

### 6. Loading Strategy

The Bronze layer currently uses a full-refresh loading approach.

Before ingestion begins, the package truncates the existing Bronze tables and reloads them from the source CSV files.

This means that each complete package execution replaces the previous Bronze contents with the latest source data.

I chose this approach for the initial implementation because it keeps the ingestion process straightforward and easier to troubleshoot.

### 7. Data Validation and Auditing

After implementing the ingestion process, I created SQL validation scripts to check whether the data was loaded correctly.

The validation focuses on three main areas:

* **Load auditing:** Checking that all nine datasets have successful ETL log entries under the same Batch ID.
* **Row count validation:** Comparing the number of records in each Bronze table against the corresponding count recorded in the ETL logging table.
* **Metadata validation:** Checking that the load timestamp, source filename and Batch ID are populated across all nine Bronze tables.

These checks help me confirm that the data has reached the correct destination, that the expected number of records has been loaded and that the ingestion process can be traced through its metadata and ETL logs.


## Silver Data Lineage

### 1. Purpose

I created the Silver layer to clean, standardise and transform the raw data ingested into the Bronze layer.

The transformations are implemented using SQL preparation views and SQL Server Integration Services (SSIS). The cleaned records are loaded into the olist_dwh database under the silver schema.

Each dataset is transformed according to its specific data quality requirements before being made available for downstream Gold layer processing.

