
USE [olist_dwh];
GO

--================================================================================
-- i am implementing scd type 2 for the customer dimension.
-- i am using customer_unique_id as the business key to identify each customer.
-- i am joining customers to orders to establish the chronological order of
-- customer location records using the order purchase timestamp.
-- i will track changes in zip code, city and state to preserve customer history.
--================================================================================

SET NOCOUNT ON;
SET XACT_ABORT ON;


--================================================================================
-- i am checking that the unknown record already exists before loading customers.
-- i am also ensuring that the dimension does not already contain customer records
-- so that this initial historical load does not create duplicate versions.
--================================================================================

IF NOT EXISTS
(
    SELECT 1
    FROM [gold].[dim_customer]
    WHERE customer_key = -1
)
BEGIN
    THROW 50001, 'the unknown customer record is missing.', 1;
END;


IF EXISTS
(
    SELECT 1
    FROM [gold].[dim_customer]
    WHERE customer_key <> -1
)
BEGIN
    THROW 50002, 'the customer dimension already contains records. initial load stopped.', 1;
END;


BEGIN TRY

    BEGIN TRANSACTION;


    --================================================================================
    -- i am resetting the identity sequence so that the next automatically
    -- generated customer surrogate key starts at 1 after the unknown record.
    --================================================================================

    DBCC CHECKIDENT ('[gold].[dim_customer]', RESEED, 0);


    --================================================================================
    -- i am retrieving customer records and joining them to orders.
    -- i am using the first order purchase timestamp associated with each
    -- customer record to establish when that location was first observed.
    --================================================================================

    ;WITH customer_observations AS
    (
        SELECT
            c.customer_unique_id,
            c.customer_id,
            c.customer_zip_code_prefix,
            c.customer_city,
            c.customer_state,

            MIN(o.order_purchase_timestamp) AS observed_from

        FROM [olist_dwh].[silver].[customers] AS c

        INNER JOIN [olist_dwh].[silver].[orders] AS o
            ON c.customer_id = o.customer_id

        WHERE c.customer_unique_id IS NOT NULL
          AND c.customer_unique_id <> 'Unknown'

        GROUP BY
            c.customer_unique_id,
            c.customer_id,
            c.customer_zip_code_prefix,
            c.customer_city,
            c.customer_state
    ),


    --================================================================================
    -- i am using lag to compare each customer location with the previous
    -- recorded location so that i can identify changes in customer information.
    --================================================================================

    customer_location_changes AS
    (
        SELECT
            customer_unique_id,
            customer_id,
            customer_zip_code_prefix,
            customer_city,
            customer_state,
            observed_from,

            LAG(customer_id) OVER
            (
                PARTITION BY customer_unique_id
                ORDER BY observed_from, customer_id
            ) AS previous_customer_id,

            LAG(customer_zip_code_prefix) OVER
            (
                PARTITION BY customer_unique_id
                ORDER BY observed_from, customer_id
            ) AS previous_zip_code,

            LAG(customer_city) OVER
            (
                PARTITION BY customer_unique_id
                ORDER BY observed_from, customer_id
            ) AS previous_city,

            LAG(customer_state) OVER
            (
                PARTITION BY customer_unique_id
                ORDER BY observed_from, customer_id
            ) AS previous_state

        FROM customer_observations
    ),


    --================================================================================
    -- i am keeping the first customer record and any subsequent record where
    -- the zip code, city or state differs from the previous location.
    -- records with unchanged location information are not treated as new versions.
    --================================================================================

    customer_versions AS
    (
        SELECT
            customer_unique_id,
            customer_zip_code_prefix,
            customer_city,
            customer_state,
            observed_from

        FROM customer_location_changes

        WHERE previous_customer_id IS NULL

           OR ISNULL(customer_zip_code_prefix, '') <>
              ISNULL(previous_zip_code, '')

           OR ISNULL(customer_city, '') <>
              ISNULL(previous_city, '')

           OR ISNULL(customer_state, '') <>
              ISNULL(previous_state, '')
    ),


    --================================================================================
    -- i am using lead to identify when the next customer location version begins.
    -- this allows me to establish the end date of the previous customer version.
    -- the latest version will have no end date and will remain current.
    --================================================================================

    customer_version_dates AS
    (
        SELECT
            customer_unique_id,
            customer_zip_code_prefix,
            customer_city,
            customer_state,
            observed_from AS valid_from,

            LEAD(observed_from) OVER
            (
                PARTITION BY customer_unique_id
                ORDER BY observed_from
            ) AS valid_to

        FROM customer_versions
    )


    --================================================================================
    -- i am inserting the customer versions into the gold customer dimension.
    -- sql server will automatically generate a new surrogate key for each version.
    -- i am using the validity dates to preserve historical customer information.
    -- the latest version will be marked as the current customer record.
    --================================================================================

    INSERT INTO [gold].[dim_customer]
    (
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        valid_from,
        valid_to,
        is_current
    )

    SELECT
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        valid_from,
        valid_to,

        CASE
            WHEN valid_to IS NULL THEN 1
            ELSE 0
        END AS is_current

    FROM customer_version_dates;


    COMMIT TRANSACTION;


    PRINT 'customer dimension scd type 2 initial load completed successfully.';


END TRY

BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
GO