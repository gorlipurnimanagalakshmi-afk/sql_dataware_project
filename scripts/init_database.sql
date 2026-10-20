/*
===============================================================================
Script Name : init_database.sql
Purpose     : Database and Schema Initialization
===============================================================================

DESCRIPTION:
    This script initializes the Data Warehouse environment.

    The script performs the following operations:
    1. Checks whether the DataWarehouse database already exists.
    2. If the database exists, drops (deletes) the existing database.
    3. Creates a new database named DataWarehouse.
    4. Creates the required schemas:
       - bronze
       - silver
       - gold

===============================================================================
WARNING:
    Running this script will permanently delete the existing
    DataWarehouse database if it already exists.

    All existing data, tables, views, stored procedures, and other
    database objects within it will be lost.

    This operation is destructive and cannot be undone through
    a normal ROLLBACK.

    Ensure that you have a valid backup before executing this script.

    DO NOT execute this script against a production database
    unless the deletion is intentional and authorized.
===============================================================================
*/

USE master;
GO
IF EXISTS (SELECT 1 FROM sys.database WHERE name='Datawarehouse')
BEGIN
  ALTER DATABASE Datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE Datawarehouse;
END;
CREATE DATABASE Datawarehouse;
USE  Datawarehouse;
--create schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
