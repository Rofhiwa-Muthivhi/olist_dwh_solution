
USE [olist_dwh];

--=========================================================
-- 1. CREATE SELLER DIMENSION TABLE
--=========================================================

IF OBJECT_ID('gold.dim_seller', 'U') IS NULL
BEGIN

    CREATE TABLE gold.dim_seller
    (
        seller_key INT IDENTITY(1,1) NOT NULL,
        seller_id VARCHAR(50) NOT NULL,
        geography_key INT NOT NULL,
        seller_city NVARCHAR(255) NOT NULL,
        seller_state NVARCHAR(255) NOT NULL,

        CONSTRAINT PK_dim_seller
            PRIMARY KEY CLUSTERED (seller_key)
    );

END;


--=========================================================
-- 2. CREATE UNIQUE INDEX ON SELLER BUSINESS KEY
--=========================================================

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UX_dim_seller_seller_id'
      AND object_id = OBJECT_ID('gold.dim_seller')
)
BEGIN

    CREATE UNIQUE NONCLUSTERED INDEX UX_dim_seller_seller_id
    ON gold.dim_seller (seller_id);

END;


--=========================================================
-- 3. CREATE GEOGRAPHY FOREIGN KEY
--=========================================================

IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_dim_seller_geography'
      AND parent_object_id = OBJECT_ID('gold.dim_seller')
)
BEGIN

    ALTER TABLE gold.dim_seller
    ADD CONSTRAINT FK_dim_seller_geography
    FOREIGN KEY (geography_key)
    REFERENCES gold.dim_geography (geography_key);

END;


--=========================================================
-- 4. INSERT UNKNOWN SELLER RECORD
--=========================================================

IF NOT EXISTS
(
    SELECT 1
    FROM gold.dim_seller
    WHERE seller_key = -1
       OR seller_id = 'Unknown'
)
BEGIN

    SET IDENTITY_INSERT gold.dim_seller ON;

    INSERT INTO gold.dim_seller
    (
        seller_key,
        seller_id,
        geography_key,
        seller_city,
        seller_state
    )
    VALUES
    (
        -1,
        'Unknown',
        -1,
        'Unknown',
        'Unknown'
    );

    SET IDENTITY_INSERT gold.dim_seller OFF;

END;
