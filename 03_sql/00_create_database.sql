
-- create staging and data warehouse databases
-- use IF DB_ID to check if the databases already exist and avoid errors when rerunning the script

IF DB_ID('olist_stg') IS NULL
BEGIN
    CREATE DATABASE olist_stg;
END;

IF DB_ID('olist_dwh') IS NULL
BEGIN
    CREATE DATABASE olist_dwh;
END;

