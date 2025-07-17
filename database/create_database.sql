SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

-- Financial Reporting Demo Database Schema
-- This script creates the database and tables for the financial reporting demo

-- Create the database
CREATE DATABASE FinancialReportingDemo;
GO

USE FinancialReportingDemo;
GO

-- Create Customers table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    CustomerName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    City NVARCHAR(50),
    Country NVARCHAR(50),
    CreatedDate DATETIME DEFAULT GETDATE()
);

-- Create Products table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    Category NVARCHAR(50),
    UnitPrice DECIMAL(10,2) NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);

-- Create Sales table
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    SaleDate DATETIME DEFAULT GETDATE(),
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    TotalAmount AS (Quantity * UnitPrice) PERSISTED,
    SalesRep NVARCHAR(50),
    Region NVARCHAR(50)
);

-- Create Expenses table
CREATE TABLE Expenses (
    ExpenseID INT PRIMARY KEY IDENTITY(1,1),
    ExpenseDate DATETIME DEFAULT GETDATE(),
    Category NVARCHAR(50) NOT NULL,
    Description NVARCHAR(200),
    Amount DECIMAL(10,2) NOT NULL,
    Department NVARCHAR(50),
    ApprovedBy NVARCHAR(50)
);


GO
-- Create Revenue Summary view
CREATE VIEW vw_RevenueSummary AS
SELECT 
    YEAR(SaleDate) as Year,
    MONTH(SaleDate) as Month,
    DATENAME(MONTH, SaleDate) as MonthName,
    Region,
    COUNT(*) as TransactionCount,
    SUM(TotalAmount) as TotalRevenue,
    AVG(TotalAmount) as AverageTransactionValue
FROM Sales
GROUP BY YEAR(SaleDate), MONTH(SaleDate), DATENAME(MONTH, SaleDate), Region;


GO
-- Create Product Performance view
CREATE VIEW vw_ProductPerformance AS
SELECT 
    p.ProductName,
    p.Category,
    COUNT(s.SaleID) as TotalSales,
    SUM(s.Quantity) as TotalQuantitySold,
    SUM(s.TotalAmount) as TotalRevenue,
    AVG(s.TotalAmount) as AverageOrderValue
FROM Products p
LEFT JOIN Sales s ON p.ProductID = s.ProductID
GROUP BY p.ProductID, p.ProductName, p.Category;


GO
-- Create Customer Analytics view
CREATE VIEW vw_CustomerAnalytics AS
SELECT 
    c.CustomerName,
    c.City,
    c.Country,
    COUNT(s.SaleID) as TotalOrders,
    SUM(s.TotalAmount) as TotalSpent,
    AVG(s.TotalAmount) as AverageOrderValue,
    MAX(s.SaleDate) as LastOrderDate
FROM Customers c
LEFT JOIN Sales s ON c.CustomerID = s.CustomerID
GROUP BY c.CustomerID, c.CustomerName, c.City, c.Country;

GO
