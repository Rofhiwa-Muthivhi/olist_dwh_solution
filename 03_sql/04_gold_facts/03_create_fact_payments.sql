USE [olist_dwh];
GO

-- ==========================================
-- create gold fact_payments table
-- ==========================================

IF OBJECT_ID('[gold].[fact_payments]', 'U') IS NOT NULL
    DROP TABLE [gold].[fact_payments];
GO

CREATE TABLE [gold].[fact_payments]
(
    payment_key INT IDENTITY(1,1) NOT NULL,

    order_id VARCHAR(50) NOT NULL,
    payment_sequential INT NOT NULL,

    customer_key INT NOT NULL,
    date_key INT NOT NULL,
    payment_type_key INT NOT NULL,

    payment_installments INT NULL,
    payment_value DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_fact_payments
        PRIMARY KEY CLUSTERED (payment_key),

    CONSTRAINT FK_fact_payments_customer
        FOREIGN KEY (customer_key)
        REFERENCES [gold].[dim_customer] (customer_key),

    CONSTRAINT FK_fact_payments_date
        FOREIGN KEY (date_key)
        REFERENCES [gold].[dim_date] (date_key),

    CONSTRAINT FK_fact_payments_payment_type
        FOREIGN KEY (payment_type_key)
        REFERENCES [gold].[dim_payment_type] (payment_type_key)
);
GO