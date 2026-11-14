/*
    olist data warehouse solution
    layer: silver
    database: olist_dwh
    schema: silver

    my objective here is to create the nine silver tables
    that will receive cleansed and transformed data from
    the bronze layer.

    unlike bronze, i am assigning appropriate data types
    to the columns because silver will contain standardised,
    validated and typed data.

    i am using if object_id to check whether each table exists
    before creating it. this allows me to rerun my script without
    attempting to recreate tables that already exist.

    i am using nvarchar(255) for descriptive text columns
    to accommodate text values and support special characters.

    i am using nvarchar(max) for customer review comments
    to preserve the full text of customer feedback.

    i am also including the dwh_load_ts metadata column in
    every silver table to capture when records are loaded.

    the etl.error_rows table will capture records that fail
    validation during the silver transformation process.
*/

USE [olist_dwh];


/* =========================================================
    customers
   ========================================================= */

/*
    i am creating the customers table to store customer
    identifiers and location information.

    the transformation process will trim spaces, standardise
    city and state names, and pad zip prefixes to five characters.
*/

IF OBJECT_ID('silver.customers', 'U') IS NULL
BEGIN
    CREATE TABLE silver.customers
    (
        customer_id                 VARCHAR(50) NOT NULL,
        customer_unique_id          VARCHAR(50),
        customer_zip_code_prefix    CHAR(5),
        customer_city               NVARCHAR(255),
        customer_state              NVARCHAR(255),

        dwh_load_ts                 DATETIME2 DEFAULT SYSDATETIME()
    );
END;


/* =========================================================
    sellers
   ========================================================= */

/*
    i am creating the sellers table to store seller identifiers
    and geographical information.

    the transformation process will standardise city and state
    names and pad zip prefixes to five characters.
*/

IF OBJECT_ID('silver.sellers', 'U') IS NULL
BEGIN
    CREATE TABLE silver.sellers
    (
        seller_id                   VARCHAR(50) NOT NULL,
        seller_zip_code_prefix      CHAR(10),
        seller_city                 NVARCHAR(255),
        seller_state                NVARCHAR(255),

        dwh_load_ts                 DATETIME2 DEFAULT SYSDATETIME()
    );
END;


/* =========================================================
    orders
   ========================================================= */

/*
    i am creating the orders table to store order identifiers,
    customer references, order statuses and lifecycle timestamps.

    the transformation process will convert timestamps to
    datetime2, standardise order statuses and derive an
    is_delivered flag.
*/

IF OBJECT_ID('silver.orders', 'U') IS NULL
BEGIN
    CREATE TABLE silver.orders
    (
        order_id                        VARCHAR(50) NOT NULL,
        customer_id                     VARCHAR(50) NOT NULL,
        order_status                    NVARCHAR(255),
        order_purchase_timestamp        DATETIME2,
        order_approved_at               DATETIME2,
        order_delivered_carrier_date    DATETIME2,
        order_delivered_customer_date   DATETIME2,
        order_estimated_delivery_date   DATETIME2,

        is_delivered                    VARCHAR(5) NOT NULL
            CONSTRAINT DF_orders_is_delivered DEFAULT 'No',

        dwh_load_ts                     DATETIME2 DEFAULT SYSDATETIME()
    );
END;

/* =========================================================
    order_items
   ========================================================= */

/*
    i am creating the order items table to store products
    associated with each order, including seller information,
    shipping dates and monetary values.

    the transformation process will convert price and freight
    values to decimal and derive the total item value.
*/

IF OBJECT_ID('silver.order_items', 'U') IS NULL
BEGIN
    CREATE TABLE silver.order_items
    (
        order_id                VARCHAR(50) NOT NULL,
        order_item_id           INT NOT NULL,
        product_id              VARCHAR(50),
        seller_id               VARCHAR(50),
        shipping_limit_date     DATETIME2,
        price                   DECIMAL(10,2),
        freight_value           DECIMAL(10,2),
        total_item_value        DECIMAL(10,2),

        dwh_load_ts             DATETIME2 DEFAULT SYSDATETIME()
    );
END;


/* =========================================================
    order_payments
   ========================================================= */

/*
    i am creating the order payments table to store payment
    information associated with each order.

    the transformation process will convert numerical columns
    to their appropriate data types and standardise payment
    types, including changing not_defined to Unknown.
*/

IF OBJECT_ID('silver.order_payments', 'U') IS NULL
BEGIN
    CREATE TABLE silver.order_payments
    (
        order_id                VARCHAR(50) NOT NULL,
        payment_sequential      INT NOT NULL,
        payment_type            NVARCHAR(255),
        payment_installments    INT,
        payment_value           DECIMAL(10,2),

        dwh_load_ts             DATETIME2 DEFAULT SYSDATETIME()
    );
END;


/* =========================================================
    order_reviews
   ========================================================= */

/*
    i am creating the order reviews table to store customer
    feedback, review scores and review response timestamps.

    the transformation process will deduplicate records using
    review_id, convert review scores to tinyint and convert
    review timestamps to datetime2.

    i am using nvarchar(max) for review comments to preserve
    the full text of customer feedback.
*/

IF OBJECT_ID('silver.order_reviews', 'U') IS NULL
BEGIN
    CREATE TABLE silver.order_reviews
    (
        review_id                   VARCHAR(50) NOT NULL,
        order_id                    VARCHAR(50),
        review_score                TINYINT,
        review_comment_title        NVARCHAR(MAX),
        review_comment_message      NVARCHAR(MAX),
        review_creation_date        DATETIME2,
        review_answer_timestamp     DATETIME2,

        dwh_load_ts                 DATETIME2 DEFAULT SYSDATETIME()
    );
END;


/* =========================================================
    products
   ========================================================= */

/*
    i am creating the products table to store product
    identifiers, category information and product measurements.

    the transformation process will correct the misspelt column
    names, convert numerical values to their appropriate data
    types and retrieve english category names through a lookup.

    products without a category will be assigned Unknown.
*/

IF OBJECT_ID('silver.products', 'U') IS NULL
BEGIN
    CREATE TABLE silver.products
    (
        product_id                  VARCHAR(50) NOT NULL,
        product_category_name       NVARCHAR(255),
        product_name_length         INT,
        product_description_length  INT,
        product_photos_qty          INT,
        product_weight_g            INT,
        product_length_cm            DECIMAL(10,2),
        product_height_cm            DECIMAL(10,2),
        product_width_cm             DECIMAL(10,2),

        dwh_load_ts                 DATETIME2 DEFAULT SYSDATETIME()
    );
END;


/* =========================================================
    product_category_name_translation
   ========================================================= */

/*
    i am creating the category translation table to store
    the original portuguese product categories and their
    corresponding english translations.

    the transformation process will also add the missing
    category translations identified in the project requirements.
*/

IF OBJECT_ID('silver.product_category_name_translation', 'U') IS NULL
BEGIN
    CREATE TABLE silver.product_category_name_translation
    (
        product_category_name           NVARCHAR(255) NOT NULL,
        product_category_name_english   NVARCHAR(255),

        dwh_load_ts                     DATETIME2 DEFAULT SYSDATETIME()
    );
END;


/* =========================================================
    geolocation
   ========================================================= */

/*
    i am creating the geolocation table to store geographical
    information associated with zip code prefixes.

    the transformation process will aggregate the bronze records
    to produce one record per zip prefix, using average latitude
    and longitude and the most frequent city.
*/

IF OBJECT_ID('silver.geolocation', 'U') IS NULL
BEGIN
    CREATE TABLE silver.geolocation
    (
        geolocation_zip_code_prefix    CHAR(5) NOT NULL,
        geolocation_lat                DECIMAL(10,8),
        geolocation_lng                DECIMAL(11,8),
        geolocation_city               NVARCHAR(255),
        geolocation_state              NVARCHAR(255),

        dwh_load_ts                    DATETIME2 DEFAULT SYSDATETIME()
    );
END;


/* =========================================================
    etl error rows
   ========================================================= */
/*
    i am creating the error rows table to capture records
    that fail validation during the silver transformation.

    this allows me to investigate and troubleshoot rejected
    records instead of silently dropping them during loading.

    the table stores information about the SSIS package,
    source dataset, affected record, error details and the
    rejected record for further investigation.

    i am also checking whether the etl schema exists before
    creating it to make the script idempotent.
*/

-- i am creating the etl schema if it does not exist
IF SCHEMA_ID('etl') IS NULL
BEGIN
    EXEC('CREATE SCHEMA etl');
END;

-- i am creating the error rows table if it does not exist
IF OBJECT_ID('etl.error_rows', 'U') IS NULL
BEGIN
    CREATE TABLE etl.error_rows
    (
        error_id                BIGINT IDENTITY(1,1),
        package_name            NVARCHAR(255),
        source_table            NVARCHAR(255),
        source_record_key       NVARCHAR(255),
        error_column            NVARCHAR(255),
        error_description       NVARCHAR(255),
        rejected_record         NVARCHAR(MAX),
        dwh_batch_id            NVARCHAR(255),
        error_ts                DATETIME2 DEFAULT SYSDATETIME()
    );
END;
