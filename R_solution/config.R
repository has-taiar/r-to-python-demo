# Database Configuration
# Copy this file to config.R and update with your actual database details

# SQL Server Express Configuration
DB_CONFIG <- list(
  # Server name - Update this with your SQL Server Express instance
  server = "financial-mcp-demo-app-sql.database.windows.net",  # Common default, might be .\SQLEXPRESS or your-computer\SQLEXPRESS
  
  # Database name - Update with your actual database name
  database = "FinancialDemoDb",
  
  # Authentication - Choose one of the options below:
  
  # Option 1: Windows Authentication (recommended for local development)
  use_windows_auth = FALSE,
  username = "sqladminuser",
  password = "Admin123!",
  
  # Option 2: SQL Server Authentication
  # use_windows_auth = FALSE,
  # username = "your_username",
  # password = "your_password",
  
  # Connection timeout
  timeout = 30
)

# Sample table structures - Update these to match your actual database schema
SAMPLE_QUERIES <- list(
  # Adjust these queries to match your actual table and column names
  sales_query = "
    SELECT 
        YEAR(OrderDate) as Year,
        MONTH(OrderDate) as Month,
        DATENAME(MONTH, OrderDate) + ' ' + CAST(YEAR(OrderDate) AS VARCHAR(4)) as MonthYear,
        SUM(TotalAmount) as TotalSales,
        COUNT(*) as OrderCount
    FROM Orders 
    WHERE OrderDate >= DATEADD(MONTH, -12, GETDATE())
    GROUP BY YEAR(OrderDate), MONTH(OrderDate), DATENAME(MONTH, OrderDate)
    ORDER BY Year, Month
  ",
  
  customers_query = "
    SELECT TOP 10
        c.CustomerID,
        c.CustomerName,
        SUM(o.TotalAmount) as TotalPurchases,
        COUNT(o.OrderID) as OrderCount,
        AVG(o.TotalAmount) as AvgOrderValue
    FROM Customers c
    INNER JOIN Orders o ON c.CustomerID = o.CustomerID
    WHERE o.OrderDate >= DATEADD(MONTH, -12, GETDATE())
    GROUP BY c.CustomerID, c.CustomerName
    ORDER BY TotalPurchases DESC
  "
)

# Example table structures you might have:
# 
# Orders table:
# - OrderID (int, primary key)
# - CustomerID (int, foreign key)
# - OrderDate (datetime)
# - TotalAmount (decimal/money)
# 
# Customers table:
# - CustomerID (int, primary key)
# - CustomerName (varchar)
# - Email (varchar)
# - etc.

cat("📝 Configuration Template Created!\n")
cat("🔧 Please update the database details in this file:\n")
cat("   - Server name (usually localhost\\SQLEXPRESS)\n")
cat("   - Database name\n")
cat("   - Table and column names in the queries\n")
cat("   - Authentication method\n")
