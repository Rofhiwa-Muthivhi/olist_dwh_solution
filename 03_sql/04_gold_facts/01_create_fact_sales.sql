USE olist_dwh;
GO

/* ==========================================
   i am creating the fact sales table
   grain: one row per order item
   ========================================== */

IF OBJECT_ID('gold.fact_sales', 'U') IS NULL
BEGIN

    CREATE TABLE gold.fact_sales
    (
        -- Fact table identifier
        sales_key BIGINT IDENTITY(1,1) NOT NULL,

        -- Source business identifiers
        order_id VARCHAR(50) NOT NULL,
        order_item_id INT NOT NULL,

        -- Dimension surrogate keys
        customer_key INT NOT NULL,
        product_key INT NOT NULL,
        seller_key INT NOT NULL,
        order_date_key INT NOT NULL,
        order_status_key INT NOT NULL,

        -- Sales measures
        price DECIMAL(10,2) NULL,
        freight_value DECIMAL(10,2) NULL,
        total_item_value DECIMAL(10,2) NULL,

        -- Delivery-related derived measures
        days_to_deliver INT NULL,
        delivery_delay_days INT NULL,
        is_late BIT NULL,

        -- Primary key
        CONSTRAINT PK_fact_sales
            PRIMARY KEY (sales_key),

        -- Prevent duplicate order items
        CONSTRAINT UQ_fact_sales_order_item
            UNIQUE (order_id, order_item_id),

        -- Dimension foreign keys
        CONSTRAINT FK_fact_sales_customer
            FOREIGN KEY (customer_key)
            REFERENCES gold.dim_customer(customer_key),

        CONSTRAINT FK_fact_sales_product
            FOREIGN KEY (product_key)
            REFERENCES gold.dim_product(product_key),

        CONSTRAINT FK_fact_sales_seller
            FOREIGN KEY (seller_key)
            REFERENCES gold.dim_seller(seller_key),

        CONSTRAINT FK_fact_sales_date
            FOREIGN KEY (order_date_key)
            REFERENCES gold.dim_date(date_key),

        CONSTRAINT FK_fact_sales_order_status
            FOREIGN KEY (order_status_key)
            REFERENCES gold.dim_order_status(order_status_key)

    );

END;
GO
