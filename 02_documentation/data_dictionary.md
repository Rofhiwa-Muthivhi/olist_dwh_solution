
## Bronze Data Dictionary

### 1. Purpose

This document describes the structure of my Bronze layer, including the nine tables, their source columns, data types, and metadata columns.

The Bronze layer is located in olist_stg.bronze. At this stage, I have created the database, schema, and table creation scripts and integrated them into my SSIS package. I have also tested that the pipeline can recreate missing databases, schemas, and tables.

### 2. Table Definitions

#### 1 Customers

**Source:** olist_customers_dataset.csv

| Column                   | Data type     | Description                        |
| ------------------------ | ------------- | ---------------------------------- |
| customer_id              | NVARCHAR(255) | Customer record identifier         |
| customer_unique_id       | NVARCHAR(255) | Customer identifier across records |
| customer_zip_code_prefix | NVARCHAR(255) | Customer postal code prefix        |
| customer_city            | NVARCHAR(255) | Customer city                      |
| customer_state           | NVARCHAR(255) | Customer state                     |

#### 2 Geolocation

**Source:** olist_geolocation_dataset.csv

| Column                      | Data type     | Description                           |
| --------------------------- | ------------- | ------------------------------------- |
| geolocation_zip_code_prefix | NVARCHAR(255) | Postal code prefix                    |
| geolocation_lat             | NVARCHAR(255) | Latitude                              |
| geolocation_lng             | NVARCHAR(255) | Longitude                             |
| geolocation_city            | NVARCHAR(255) | City associated with the postal code  |
| geolocation_state           | NVARCHAR(255) | State associated with the postal code |

#### 3 Order Items

**Source:** olist_order_items_dataset.csv

| Column              | Data type     | Description                   |
| ------------------- | ------------- | ----------------------------- |
| order_id            | NVARCHAR(255) | Order identifier              |
| order_item_id       | NVARCHAR(255) | Item sequence within an order |
| product_id          | NVARCHAR(255) | Product identifier            |
| seller_id           | NVARCHAR(255) | Seller identifier             |
| shipping_limit_date | NVARCHAR(255) | Shipping deadline             |
| price               | NVARCHAR(255) | Item price                    |
| freight_value       | NVARCHAR(255) | Shipping cost                 |

#### 4 Order Payments

**Source:** olist_order_payments_dataset.csv

| Column               | Data type     | Description                      |
| -------------------- | ------------- | -------------------------------- |
| order_id             | NVARCHAR(255) | Order identifier                 |
| payment_sequential   | NVARCHAR(255) | Payment sequence within an order |
| payment_type         | NVARCHAR(255) | Payment method                   |
| payment_installments | NVARCHAR(255) | Number of payment instalments    |
| payment_value        | NVARCHAR(255) | Payment amount                   |

#### 5 Order Reviews

**Source:** olist_order_reviews_dataset.csv

| Column                  | Data type     | Description                 |
| ----------------------- | ------------- | --------------------------- |
| review_id               | NVARCHAR(255) | Review identifier           |
| order_id                | NVARCHAR(255) | Associated order identifier |
| review_score            | NVARCHAR(255) | Customer review score       |
| review_comment_title    | NVARCHAR(MAX) | Review title                |
| review_comment_message  | NVARCHAR(MAX) | Review message              |
| review_creation_date    | NVARCHAR(255) | Review creation date        |
| review_answer_timestamp | NVARCHAR(255) | Review response timestamp   |

#### 6 Orders

**Source:** olist_orders_dataset.csv

| Column                        | Data type     | Description                             |
| ----------------------------- | ------------- | --------------------------------------- |
| order_id                      | NVARCHAR(255) | Order identifier                        |
| customer_id                   | NVARCHAR(255) | Customer record identifier              |
| order_status                  | NVARCHAR(255) | Current order status in the source data |
| order_purchase_timestamp      | NVARCHAR(255) | Order purchase timestamp                |
| order_approved_at             | NVARCHAR(255) | Order approval timestamp                |
| order_delivered_carrier_date  | NVARCHAR(255) | Date handed to the carrier              |
| order_delivered_customer_date | NVARCHAR(255) | Customer delivery date                  |
| order_estimated_delivery_date | NVARCHAR(255) | Estimated delivery date                 |

#### 7 Products

**Source:** olist_products_dataset.csv

| Column                     | Data type     | Description                                                  |
| -------------------------- | ------------- | ------------------------------------------------------------ |
| product_id                 | NVARCHAR(255) | Product identifier                                           |
| product_category_name      | NVARCHAR(255) | Product category                                             |
| product_name_lenght        | NVARCHAR(255) | Product name length, using the source column spelling        |
| product_description_lenght | NVARCHAR(255) | Product description length, using the source column spelling |
| product_photos_qty         | NVARCHAR(255) | Number of product photos                                     |
| product_weight_g           | NVARCHAR(255) | Product weight in grams                                      |
| product_length_cm          | NVARCHAR(255) | Product length in centimetres                                |
| product_height_cm          | NVARCHAR(255) | Product height in centimetres                                |
| product_width_cm           | NVARCHAR(255) | Product width in centimetres                                 |

#### 8 Sellers

**Source:** olist_sellers_dataset.csv

| Column                 | Data type     | Description               |
| ---------------------- | ------------- | ------------------------- |
| seller_id              | NVARCHAR(255) | Seller identifier         |
| seller_zip_code_prefix | NVARCHAR(255) | Seller postal code prefix |
| seller_city            | NVARCHAR(255) | Seller city               |
| seller_state           | NVARCHAR(255) | Seller state              |

#### 9 Product Category Translation

**Source:** product_category_name_translation.csv

| Column  | Data type     | Description                                                                   |
| ------- | ------------- | ----------------------------------------------------------------------------- |
| column1 | NVARCHAR(255) | Source column retained as imported; verify its meaning against the CSV header |
| column2 | NVARCHAR(255) | Source column retained as imported; verify its meaning against the CSV header |

### 3. Metadata Columns

I added three metadata columns to each Bronze table to support data traceability.

| Column          | Data type     | Purpose                                                                               |
| --------------- | ------------- | ------------------------------------------------------------------------------------- |
| dwh_load_ts     | DATETIME2     | Records the load timestamp. The table definition uses SYSDATETIME() as its default. |
| dwh_source_file | NVARCHAR(260) | Identifies the source file associated with the data.                                  |
| dwh_batch_id    | INT           | Identifies the ingestion batch associated with the data.                              |

### 4. Design Notes

* I kept the source columns as text in the Bronze layer to retain the incoming values before applying transformations.
* I added metadata columns to help trace the source file, load timestamp, and ingestion batch.
* I made sure the pipeline creates tables only when they don't already exist.
* Data type conversions, data quality checks, and other transformations will be handled as I develop the Silver layer.

### 5. ETL Logging Infrastructure

I created an etl schema inside olist_stg to store information about the data ingestion process.

I also created the etl.load_log table to record the number of rows loaded from each source file, the batch ID, the load timestamp, and the load status.

I kept this separate from the Bronze tables because it serves a different purpose. The Bronze tables store the source data, while the logging table helps me track and validate the ingestion process.

I will integrate the etl logging infrastructure  into 01_bronze_load.dtsx so that the package can record the results of each file load.

Table: olist_stg.etl.load_log

| Column          | Purpose                                     |
| --------------- | --------------------------------------------|
| load_log_id     | identifies each logging record.             |
| batch_id        | Identifies the ingestion batch.             |
| source_file     | records the source csv filename.            |
| rows_loaded     | records the number of rows loaded.          |
| load_timestamp  | records when the logging entry was created. |


# Silver Data Dictionary

## 1. Purpose

This document describes the structure of my Silver layer, including the nine tables, their columns, data types and the purpose of each column.

The Silver layer is located in the olist_dwh database under the silver schema.

The tables contain cleaned and standardised data that is used for downstream Gold layer processing.

## 2. Table Definitions

### 2.1 Customers

**Source:** olist_stg.bronze.customers

**Destination:** olist_dwh.silver.customers

| Column | Data type | Description |
|---|---|---|
| customer_id | VARCHAR(50) | Identifier for an individual customer record. |
| customer_unique_id | VARCHAR(50) | Unique identifier representing a customer across multiple records. |
| customer_zip_code_prefix | CHAR(5) | Five-character customer ZIP code prefix. |
| customer_city | NVARCHAR(255) | Customer's city, with standardised text formatting. |
| customer_state | NVARCHAR(255) | Customer's state abbreviation, standardised to uppercase. |
| dwh_load_ts | DATETIME2 | Timestamp indicating when the record was loaded into the Silver layer. |

### 2.2 Sellers

**Source:** olist_stg.bronze.sellers

**Destination:** olist_dwh.silver.sellers

| Column | Data type | Description |
|---|---|---|
| seller_id | VARCHAR(50) | Unique identifier for a seller. |
| seller_zip_code_prefix | CHAR(10) | Seller's ZIP code prefix. |
| seller_city | NVARCHAR(255) | Seller's city, with standardised text formatting. |
| seller_state | NVARCHAR(255) | Seller's state abbreviation, standardised to uppercase. |
| dwh_load_ts | DATETIME2 | Timestamp indicating when the record was loaded into the Silver layer. |

### 2.3 Orders

**Source:** olist_stg.bronze.orders

**Destination:** olist_dwh.silver.orders

| Column | Data type | Description |
|---|---|---|
| order_id | VARCHAR(50) | Unique identifier for an order. |
| customer_id | VARCHAR(50) | Identifier linking the order to a customer. |
| order_status | NVARCHAR(255) | Current status of the order, standardised to uppercase. |
| order_purchase_timestamp | DATETIME2 | Date and time when the order was placed. |
| order_approved_at | DATETIME2 | Date and time when the order was approved. |
| order_delivered_carrier_date | DATETIME2 | Date and time when the order was handed over to the carrier. |
| order_delivered_customer_date | DATETIME2 | Date and time when the order was delivered to the customer. |
| order_estimated_delivery_date | DATETIME2 | Estimated delivery date for the order. |
| is_delivered | VARCHAR(5) | Indicates whether the order has been delivered. |
| dwh_load_ts | DATETIME2 | Timestamp indicating when the record was loaded into the Silver layer. |

### 2.4 Order Items

**Source:** olist_stg.bronze.order_items

**Destination:** olist_dwh.silver.order_items

| Column | Data type | Description |
|---|---|---|
| order_id | VARCHAR(50) | Identifier linking the item to an order. |
| order_item_id | INT | Sequential number identifying an item within an order. |
| product_id | VARCHAR(50) | Identifier for the purchased product. |
| seller_id | VARCHAR(50) | Identifier for the seller supplying the product. |
| shipping_limit_date | DATETIME2 | Deadline by which the seller must hand the item over for shipping. |
| price | DECIMAL(10,2) | Price of the purchased item. |
| freight_value | DECIMAL(10,2) | Freight cost associated with the item. |
| total_item_value | DECIMAL(10,2) | Calculated value obtained by adding the item price and freight value. |
| dwh_load_ts | DATETIME2 | Timestamp indicating when the record was loaded into the Silver layer. |

### 2.5 Order Payments

**Source:** olist_stg.bronze.order_payments

**Destination:** olist_dwh.silver.order_payments

| Column | Data type | Description |
|---|---|---|
| order_id | VARCHAR(50) | Identifier linking the payment to an order. |
| payment_sequential | INT | Sequential number identifying a payment within an order. |
| payment_type | NVARCHAR(255) | Payment method used by the customer. |
| payment_installments | INT | Number of instalments used for the payment. |
| payment_value | DECIMAL(10,2) | Monetary value of the payment. |
| dwh_load_ts | DATETIME2 | Timestamp indicating when the record was loaded into the Silver layer. |

### 2.6 Order Reviews

**Source:** olist_stg.bronze.order_reviews

**Destination:** olist_dwh.silver.order_reviews

| Column | Data type | Description |
|---|---|---|
| review_id | VARCHAR(50) | Unique identifier for a customer review. |
| order_id | VARCHAR(50) | Identifier linking the review to an order. |
| review_score | TINYINT | Customer rating assigned to the order, ranging from 1 to 5. |
| review_comment_title | NVARCHAR(MAX) | Title provided by the customer in the review. |
| review_comment_message | NVARCHAR(MAX) | Written feedback provided by the customer. |
| review_creation_date | DATETIME2 | Date and time when the review was created. |
| review_answer_timestamp | DATETIME2 | Date and time when the review was answered. |
| dwh_load_ts | DATETIME2 | Timestamp indicating when the record was loaded into the Silver layer. |

### 2.7 Products

**Source:** olist_stg.bronze.products

**Destination:** olist_dwh.silver.products

| Column | Data type | Description |
|---|---|---|
| product_id | VARCHAR(50) | Unique identifier for a product. |
| product_category_name | NVARCHAR(255) | Original Portuguese product category name. |
| product_name_length | INT | Length of the product name. |
| product_description_length | INT | Length of the product description. |
| product_photos_qty | INT | Number of photos associated with the product. |
| product_weight_g | INT | Product weight measured in grams. |
| product_length_cm | DECIMAL(10,2) | Product length measured in centimetres. |
| product_height_cm | DECIMAL(10,2) | Product height measured in centimetres. |
| product_width_cm | DECIMAL(10,2) | Product width measured in centimetres. |
| dwh_load_ts | DATETIME2 | Timestamp indicating when the record was loaded into the Silver layer. |

### 2.8 Geolocation

**Source:** olist_stg.bronze.geolocation

**Destination:** olist_dwh.silver.geolocation

| Column | Data type | Description |
|---|---|---|
| geolocation_zip_code_prefix | CHAR(5) | Five-character ZIP code prefix used to identify a geographical area. |
| geolocation_lat | DECIMAL(10,8) | Average latitude recorded for the ZIP code prefix. |
| geolocation_lng | DECIMAL(11,8) | Average longitude recorded for the ZIP code prefix. |
| geolocation_city | NVARCHAR(255) | Most frequently occurring city associated with the ZIP code prefix. |
| geolocation_state | NVARCHAR(255) | Most frequently occurring state associated with the ZIP code prefix. |
| dwh_load_ts | DATETIME2 | Timestamp indicating when the record was loaded into the Silver layer. |

### 2.9 Product Category Name Translation

**Source:** olist_stg.bronze.product_category_name_translation

**Destination:** olist_dwh.silver.product_category_name_translation

| Column | Data type | Description |
|---|---|---|
| product_category_name | NVARCHAR(255) | Original Portuguese product category name. |
| product_category_name_english | NVARCHAR(255) | English translation of the product category name. |
| dwh_load_ts | DATETIME2 | Timestamp indicating when the record was loaded into the Silver layer. |

## 3. Metadata Columns

The Silver tables retain the following metadata column:

| Column | Data type | Description |
|---|---|---|
| dwh_load_ts | DATETIME2 | Records the timestamp associated with the data load into the Silver layer. |

## 4. Design Notes

- The Silver layer contains nine tables created from the original Bronze datasets.
- Source identifiers are stored using VARCHAR(50) in the destination tables.
- Location fields are standardised, and ZIP code prefixes are stored using fixed-length character columns.
- Date and time fields are stored using DATETIME2.
- Monetary values are stored using DECIMAL(10,2).
- Review comments are stored using NVARCHAR(MAX) to preserve the original text.
- The product table contains corrected column names for product measurements and descriptions.
- The geolocation table contains aggregated geographical information based on ZIP code prefixes.
- The order items table includes the calculated total_item_value column.
- The product category translation table contains Portuguese category names and their English translations.

## 5. ETL Error Logging Infrastructure

The Silver transformation process uses the etl.error_rows table in the olist_dwh database to capture records identified as invalid during data quality checks.

Invalid records are redirected to this table through SSIS Conditional Split transformations, allowing them to be retained for investigation and troubleshooting rather than being loaded into the Silver destination tables.


## Gold Layer

### 1. Purpose

This section describes the structure of my Gold layer, including its dimension and fact tables, their columns, data types and the purpose of each column.

The Gold layer is located in the olist_dwh database under the gold schema.

### 2. Table Definitions

#### 2.1 Date Dimension

**Source:** Generated using SQL Server.

**Destination:**`olist_dwh.gold.dim_date

| Column | Data type | Description |
|---|---|---|
| date_key | INT | Primary key used to uniquely identify each date. The value -1 represents an Unknown date. |
| full_date | DATE | Actual calendar date represented by the record. |
| day_of_month | TINYINT | Day of the month, ranging from 1 to 31. |
| day_of_week_number | TINYINT | Numeric representation of the day of the week. |
| day_name | NVARCHAR(10) | Name of the day, such as Monday or Tuesday. |
| week_of_year | TINYINT | Week number within the year, based on the ISO week numbering system. |
| month_number | TINYINT | Numeric representation of the month, ranging from 1 to 12. |
| month_name | NVARCHAR(10) | Name of the month, such as January or February. |
| quarter_number | TINYINT | Calendar quarter, ranging from 1 to 4. |
| year_number | SMALLINT | Calendar year represented by the date. |
| is_weekend | BIT | Indicates whether the date falls on a Saturday or Sunday. |

