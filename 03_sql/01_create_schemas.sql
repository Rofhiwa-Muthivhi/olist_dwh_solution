
-- create schemas
-- use IF SCHEMA_ID to check if the schemas already exist and avoid errors when rerunning the script

-- create bronze schema in the staging database
USE olist_stg;

IF SCHEMA_ID('bronze') IS NULL
BEGIN
    EXEC('CREATE SCHEMA bronze');
END;

-- create silver and gold schemas in the data warehouse database
USE olist_dwh;

IF SCHEMA_ID('silver') IS NULL
BEGIN
    EXEC('CREATE SCHEMA silver');
END;

IF SCHEMA_ID('gold') IS NULL
BEGIN
    EXEC('CREATE SCHEMA gold');
END;


