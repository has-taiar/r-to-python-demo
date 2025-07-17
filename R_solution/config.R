# Database Configuration
# Copy this file to config.R and update with your actual database details

# SQL Server Express Configuration
DB_CONFIG <- list(
  # Server name - Update this with your SQL Server Express instance
  server = "localhost\\SQLEXPRESS",  # "financial-mcp-demo-app-sql.database.windows.net",  # Common default, might be .\SQLEXPRESS or your-computer\SQLEXPRESS
  
  # Database name - Update with your actual database name
  database = "FinancialReportingDemo",
  
  # Authentication - Using environment variables for security
  
  # Option 1: Windows Authentication (recommended for local development)
  use_windows_auth = TRUE,
  username = Sys.getenv("DB_USERNAME"),
  password = Sys.getenv("DB_PASSWORD"),
  
  # Note: Set environment variables before running:
  # Windows PowerShell:
  #   $env:DB_USERNAME = "sqladminuser"
  #   $env:DB_PASSWORD = "Admin123!"
  # 
  # Windows Command Prompt:
  #   set DB_USERNAME=sqladminuser
  #   set DB_PASSWORD=Admin123!
  #
  # Linux/Mac:
  #   export DB_USERNAME=sqladminuser
  #   export DB_PASSWORD=Admin123!
  
  # Connection timeout
  timeout = 30
)

# Sample table structures - Update these to match your actual database schema
SAMPLE_QUERIES <- list(
  # Adjust these queries to match your actual table and column names
  sales_query = "
    SELECT 
        YEAR(SaleDate) as Year,
        MONTH(SaleDate) as Month,
        DATENAME(MONTH, SaleDate) + ' ' + CAST(YEAR(SaleDate) AS VARCHAR(4)) as MonthYear,
        SUM(TotalAmount) as TotalSales,
        COUNT(*) as OrderCount
    FROM Sales 
    WHERE SaleDate >= DATEADD(MONTH, -12, GETDATE())
    GROUP BY YEAR(SaleDate), MONTH(SaleDate), DATENAME(MONTH, SaleDate)
    ORDER BY Year, Month
  ",
  
  customers_query = "
    SELECT TOP 10
        c.CustomerName,
        c.City + ', ' + c.Country as Location,
        SUM(s.TotalAmount) as TotalPurchases,
        COUNT(s.SaleID) as OrderCount
    FROM Customers c
    INNER JOIN Sales s ON c.CustomerID = s.CustomerID
    WHERE s.SaleDate >= DATEADD(MONTH, -12, GETDATE())
    GROUP BY c.CustomerName, c.City, c.Country
    ORDER BY TotalPurchases DESC
  "
)

# Validate environment variables are set
if (!DB_CONFIG$use_windows_auth && (nchar(DB_CONFIG$username) == 0 || nchar(DB_CONFIG$password) == 0)) {
  cat("❌ Error: Database credentials not found in environment variables!\n")
  cat("📝 Please set the following environment variables:\n")
  cat("   Windows PowerShell:\n")
  cat("     $env:DB_USERNAME = \"your_username\"\n")
  cat("     $env:DB_PASSWORD = \"your_password\"\n")
  cat("\n   Or copy .env.example to .env and load it\n")
  stop("Missing database credentials in environment variables")
}

cat("✅ Database configuration loaded successfully!\n")
cat(sprintf("🔗 Server: %s\n", DB_CONFIG$server))
cat(sprintf("🗃️  Database: %s\n", DB_CONFIG$database))
cat(sprintf("👤 Username: %s\n", DB_CONFIG$username))
