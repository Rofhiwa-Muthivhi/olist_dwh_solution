
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

