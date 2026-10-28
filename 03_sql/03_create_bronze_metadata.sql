USE olist_stg;
GO

/*
i am adding metadata columns to my bronze tables.
these columns will help me track when the data was loaded,
which file it came from, and which batch loaded it.
*/

-- customers

IF COL_LENGTH('bronze.customers', 'dwh_load_ts') IS NULL
BEGIN
    ALTER TABLE bronze.customers
    ADD dwh_load_ts DATETIME2 DEFAULT SYSDATETIME();
END;

IF COL_LENGTH('bronze.customers', 'dwh_source_file') IS NULL
BEGIN
    ALTER TABLE bronze.customers
    ADD dwh_source_file NVARCHAR(260);
END;

IF COL_LENGTH('bronze.customers', 'dwh_batch_id') IS NULL
BEGIN
    ALTER TABLE bronze.customers
    ADD dwh_batch_id INT;
END;


-- geolocation

IF COL_LENGTH('bronze.geolocation', 'dwh_load_ts') IS NULL
BEGIN
    ALTER TABLE bronze.geolocation
    ADD dwh_load_ts DATETIME2 DEFAULT SYSDATETIME();
END;

IF COL_LENGTH('bronze.geolocation', 'dwh_source_file') IS NULL
BEGIN
    ALTER TABLE bronze.geolocation
    ADD dwh_source_file NVARCHAR(260);
END;

IF COL_LENGTH('bronze.geolocation', 'dwh_batch_id') IS NULL
BEGIN
    ALTER TABLE bronze.geolocation
    ADD dwh_batch_id INT;
END;


-- order_items

IF COL_LENGTH('bronze.order_items', 'dwh_load_ts') IS NULL
BEGIN
    ALTER TABLE bronze.order_items
    ADD dwh_load_ts DATETIME2 DEFAULT SYSDATETIME();
END;

IF COL_LENGTH('bronze.order_items', 'dwh_source_file') IS NULL
BEGIN
    ALTER TABLE bronze.order_items
    ADD dwh_source_file NVARCHAR(260);
END;

IF COL_LENGTH('bronze.order_items', 'dwh_batch_id') IS NULL
BEGIN
    ALTER TABLE bronze.order_items
    ADD dwh_batch_id INT;
END;


-- order_payments

IF COL_LENGTH('bronze.order_payments', 'dwh_load_ts') IS NULL
BEGIN
    ALTER TABLE bronze.order_payments
    ADD dwh_load_ts DATETIME2 DEFAULT SYSDATETIME();
END;

IF COL_LENGTH('bronze.order_payments', 'dwh_source_file') IS NULL
BEGIN
    ALTER TABLE bronze.order_payments
    ADD dwh_source_file NVARCHAR(260);
END;

IF COL_LENGTH('bronze.order_payments', 'dwh_batch_id') IS NULL
BEGIN
    ALTER TABLE bronze.order_payments
    ADD dwh_batch_id INT;
END;


-- order_reviews

IF COL_LENGTH('bronze.order_reviews', 'dwh_load_ts') IS NULL
BEGIN
    ALTER TABLE bronze.order_reviews
    ADD dwh_load_ts DATETIME2 DEFAULT SYSDATETIME();
END;

IF COL_LENGTH('bronze.order_reviews', 'dwh_source_file') IS NULL
BEGIN
    ALTER TABLE bronze.order_reviews
    ADD dwh_source_file NVARCHAR(260);
END;

IF COL_LENGTH('bronze.order_reviews', 'dwh_batch_id') IS NULL
BEGIN
    ALTER TABLE bronze.order_reviews
    ADD dwh_batch_id INT;
END;


-- orders

IF COL_LENGTH('bronze.orders', 'dwh_load_ts') IS NULL
BEGIN
    ALTER TABLE bronze.orders
    ADD dwh_load_ts DATETIME2 DEFAULT SYSDATETIME();
END;

IF COL_LENGTH('bronze.orders', 'dwh_source_file') IS NULL
BEGIN
    ALTER TABLE bronze.orders
    ADD dwh_source_file NVARCHAR(260);
END;

IF COL_LENGTH('bronze.orders', 'dwh_batch_id') IS NULL
BEGIN
    ALTER TABLE bronze.orders
    ADD dwh_batch_id INT;
END;


-- product_category_name_translation

IF COL_LENGTH('bronze.product_category_name_translation', 'dwh_load_ts') IS NULL
BEGIN
    ALTER TABLE bronze.product_category_name_translation
    ADD dwh_load_ts DATETIME2 DEFAULT SYSDATETIME();
END;

IF COL_LENGTH('bronze.product_category_name_translation', 'dwh_source_file') IS NULL
BEGIN
    ALTER TABLE bronze.product_category_name_translation
    ADD dwh_source_file NVARCHAR(260);
END;

IF COL_LENGTH('bronze.product_category_name_translation', 'dwh_batch_id') IS NULL
BEGIN
    ALTER TABLE bronze.product_category_name_translation
    ADD dwh_batch_id INT;
END;


-- products

IF COL_LENGTH('bronze.products', 'dwh_load_ts') IS NULL
BEGIN
    ALTER TABLE bronze.products
    ADD dwh_load_ts DATETIME2 DEFAULT SYSDATETIME();
END;

IF COL_LENGTH('bronze.products', 'dwh_source_file') IS NULL
BEGIN
    ALTER TABLE bronze.products
    ADD dwh_source_file NVARCHAR(260);
END;

IF COL_LENGTH('bronze.products', 'dwh_batch_id') IS NULL
BEGIN
    ALTER TABLE bronze.products
    ADD dwh_batch_id INT;
END;


-- sellers

IF COL_LENGTH('bronze.sellers', 'dwh_load_ts') IS NULL
BEGIN
    ALTER TABLE bronze.sellers
    ADD dwh_load_ts DATETIME2 DEFAULT SYSDATETIME();
END;

IF COL_LENGTH('bronze.sellers', 'dwh_source_file') IS NULL
BEGIN
    ALTER TABLE bronze.sellers
    ADD dwh_source_file NVARCHAR(260);
END;

IF COL_LENGTH('bronze.sellers', 'dwh_batch_id') IS NULL
BEGIN
    ALTER TABLE bronze.sellers
    ADD dwh_batch_id INT;
END;