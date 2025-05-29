-- SQL SECURITY TASK: Schema-Level Access Control
-- Step 1: Create Database
CREATE DATABASE CompanyDB;
GO
USE CompanyDB;
GO
-- Step 2: Create Schemas
CREATE SCHEMA HR;
GO
CREATE SCHEMA Sales;
GO
-- Step 3: Create Tables for Each Department
CREATE TABLE HR.Employees (
    EmployeeID INT PRIMARY KEY,
    Name NVARCHAR(100),
    Position NVARCHAR(100),
    Salary DECIMAL(10, 2)
);
GO
CREATE TABLE Sales.Customers (
    CustomerID INT PRIMARY KEY,
    Name NVARCHAR(100),
    PurchaseAmount DECIMAL(10, 2)
);
GO
-- Step 4: Create Logins and Users
CREATE LOGIN hr_login WITH PASSWORD = 'Hr@12345';
CREATE USER hr_user FOR LOGIN hr_login;
GO
CREATE LOGIN sales_login WITH PASSWORD = 'Sales@12345';
CREATE USER sales_user FOR LOGIN sales_login;
GO
-- Step 5: Grant Schema-Level Permissions
-- HR user access only HR schema
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::HR TO hr_user;
DENY SELECT ON SCHEMA::Sales TO hr_user;
GO
-- Sales user access only Sales schema
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::Sales TO sales_user;
DENY SELECT ON SCHEMA::HR TO sales_user;
GO
-- Step 6: Bonus Activity — Read-Only Role
CREATE ROLE ReadOnly_Dev;
GRANT SELECT ON SCHEMA::HR TO ReadOnly_Dev;
EXEC sp_addrolemember 'ReadOnly_Dev', 'hr_user';
GO
-- ==========================================
-- Testing Instructions (to be run separately)
-- ==========================================
--  As hr_login
-- SELECT * FROM HR.Employees;
--  As hr_login
-- SELECT * FROM Sales.Customers;
--  As sales_login
-- SELECT * FROM Sales.Customers;
--  As sales_login
-- SELECT * FROM HR.Employees;
--  As hr_user with ReadOnly_Dev role
-- INSERT INTO HR.Employees VALUES (4, 'Test User', 'Temp', 9000);
-- DELETE FROM HR.Employees WHERE EmployeeID = 1;