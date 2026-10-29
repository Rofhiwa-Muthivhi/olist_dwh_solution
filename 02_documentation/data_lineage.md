
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

The source CSV files will be ingested using SSIS and loaded into their corresponding Bronze tables.

The Bronze tables retain the source columns and include metadata columns to support data traceability.

At this stage, I have created the Bronze tables and integrated their creation into my SSIS package. I will validate the actual data flow after implementing the CSV ingestion process.


