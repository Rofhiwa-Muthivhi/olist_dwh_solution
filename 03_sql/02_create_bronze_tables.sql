
/*
    olist data warehouse solution
    layer: bronze
    database: olist_stg
    schema: bronze

    my objective here is to create the nine bronze tables
    that will receive data from my olist source csv files.

    i am using if object_id to check whether each table exists
    before creating it. this allows me to rerun my script without
    attempting to recreate tables that already exist.

    at this stage, i am using nvarchar for every column because
    i want to land the source data as text before applying
    transformations in the silver layer.
*/

USE [olist_stg];


/* =========================================================
   1. customers
   ========================================================= */

/*
    i am creating the customers table to store the customer
    identifiers and location information from the source dataset.
*/

IF OBJECT_ID('bronze.customers', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.customers
    (
        customer_id                 NVARCHAR(255),
        customer_unique_id          NVARCHAR(255),
        customer_zip_code_prefix    NVARCHAR(255),
        customer_city               NVARCHAR(255),
        customer_state              NVARCHAR(255)
    );
END;



/* =========================================================
   2. geolocation
   ========================================================= */

/*
    i am creating the geolocation table to store the location
    information associated with zip code prefixes.

    i am keeping the latitude and longitude as text for now.
    i can convert them to appropriate numeric types in silver.
*/

IF OBJECT_ID('bronze.geolocation', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.geolocation
    (
        geolocation_zip_code_prefix NVARCHAR(255),
        geolocation_lat             NVARCHAR(255),
        geolocation_lng             NVARCHAR(255),
        geolocation_city            NVARCHAR(255),
        geolocation_state           NVARCHAR(255)
    );
END;



/* =========================================================
   3. order items
   ========================================================= */

/*
    i am creating the order_items table to capture the products
    associated with each order, including the seller and pricing.

    i am keeping the dates and monetary values as text in bronze.
*/

IF OBJECT_ID('bronze.order_items', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.order_items
    (
        order_id            NVARCHAR(255),
        order_item_id       NVARCHAR(255),
        product_id          NVARCHAR(255),
        seller_id           NVARCHAR(255),
        shipping_limit_date NVARCHAR(255),
        price               NVARCHAR(255),
        freight_value       NVARCHAR(255)
    );
END;



/* =========================================================
   4. order payments
   ========================================================= */

/*
    i am creating the order_payments table to capture payment
    information, including payment type, instalments and value.

    i will handle the appropriate data type conversions later.
*/

IF OBJECT_ID('bronze.order_payments', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.order_payments
    (
        order_id             NVARCHAR(255),
        payment_sequential   NVARCHAR(255),
        payment_type         NVARCHAR(255),
        payment_installments NVARCHAR(255),
        payment_value        NVARCHAR(255)
    );
END;



/* =========================================================
   5. order reviews
   ========================================================= */

/*
    i am creating the order_reviews table to store customer
    feedback, review scores and review timestamps.

    i am using nvarchar(max) for the review comments because
    the messages can be longer than the other source fields.
*/

IF OBJECT_ID('bronze.order_reviews', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.order_reviews
    (
        review_id               NVARCHAR(255),
        order_id                NVARCHAR(255),
        review_score            NVARCHAR(255),
        review_comment_title    NVARCHAR(MAX),
        review_comment_message  NVARCHAR(MAX),
        review_creation_date    NVARCHAR(255),
        review_answer_timestamp NVARCHAR(255)
    );
END;



/* =========================================================
   6. orders
   ========================================================= */

/*
    i am creating the orders table to capture the order status
    and the different timestamps associated with each order.

    i am landing the timestamps as text so i can validate and
    convert them during silver-layer processing.
*/

IF OBJECT_ID('bronze.orders', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.orders
    (
        order_id                       NVARCHAR(255),
        customer_id                    NVARCHAR(255),
        order_status                   NVARCHAR(255),
        order_purchase_timestamp       NVARCHAR(255),
        order_approved_at              NVARCHAR(255),
        order_delivered_carrier_date   NVARCHAR(255),
        order_delivered_customer_date  NVARCHAR(255),
        order_estimated_delivery_date  NVARCHAR(255)
    );
END;



/* =========================================================
   7. products
   ========================================================= */

/*
    i am creating the products table to store product details,
    including the category, dimensions, weight and photo count.

    i am keeping the measurements as text for now.
*/

IF OBJECT_ID('bronze.products', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.products
    (
        product_id                   NVARCHAR(255),
        product_category_name        NVARCHAR(255),
        product_name_lenght          NVARCHAR(255),
        product_description_lenght   NVARCHAR(255),
        product_photos_qty           NVARCHAR(255),
        product_weight_g             NVARCHAR(255),
        product_length_cm            NVARCHAR(255),
        product_height_cm            NVARCHAR(255),
        product_width_cm             NVARCHAR(255)
    );
END;


/* =========================================================
   8. sellers
   ========================================================= */

/*
    i am creating the sellers table to store seller identifiers
    and their location information.
*/

IF OBJECT_ID('bronze.sellers', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.sellers
    (
        seller_id              NVARCHAR(255),
        seller_zip_code_prefix NVARCHAR(255),
        seller_city            NVARCHAR(255),
        seller_state           NVARCHAR(255)
    );
END;



/* =========================================================
   9. product category name translation
   ========================================================= */

/*
    i am creating the product category translation table
    to store the category names and their translations.

    my source currently exposes these columns as column1
    and column2. i am preserving those names for now.
    i can confirm their actual meanings before transforming
    them in the silver layer.
*/

IF OBJECT_ID('bronze.product_category_name_translation', 'U') IS NULL
BEGIN
    CREATE TABLE bronze.product_category_name_translation
    (
        column1 NVARCHAR(255),
        column2 NVARCHAR(255)
    );
END;


