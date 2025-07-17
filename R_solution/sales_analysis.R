# Simple Sales Analytics Dashboard
# Creates visualizations for FinancialReportingDemo database

# Load libraries
library(DBI)
library(odbc)
library(ggplot2)
library(plotly)
library(htmlwidgets)
library(scales)

# Database connection parameters
DB_CONFIG <- list(
  server = "localhost\\SQLEXPRESS",
  database = "FinancialReportingDemo",  # Updated to match create_database.sql
  driver = "ODBC Driver 17 for SQL Server",
  trusted_connection = "yes"
)

# Create connection string
connection_string <- paste0(
  "Driver={", DB_CONFIG$driver, "};",
  "Server=", DB_CONFIG$server, ";",
  "Database=", DB_CONFIG$database, ";",
  "Trusted_Connection=", DB_CONFIG$trusted_connection, ";"
)

# Database connection
con <- dbConnect(odbc::odbc(), .connection_string = connection_string)
cat("✅ Connected to", DB_CONFIG$database, "database\n")

# SQL Queries - Based on actual database schema
sales_by_month_query <- "
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
"

top_customers_query <- "
SELECT TOP 10
    c.CustomerName,
    c.City,
    c.Country,
    SUM(s.TotalAmount) as TotalPurchases,
    COUNT(s.SaleID) as OrderCount,
    AVG(s.TotalAmount) as AvgOrderValue
FROM Customers c
INNER JOIN Sales s ON c.CustomerID = s.CustomerID
WHERE s.SaleDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY c.CustomerName, c.City, c.Country
ORDER BY TotalPurchases DESC
"

top_products_query <- "
SELECT TOP 10
    p.ProductName,
    p.Category,
    SUM(s.Quantity) as TotalQuantitySold,
    SUM(s.TotalAmount) as TotalRevenue,
    COUNT(s.SaleID) as TotalOrders
FROM Products p
INNER JOIN Sales s ON p.ProductID = s.ProductID
WHERE s.SaleDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY p.ProductName, p.Category
ORDER BY TotalRevenue DESC
"

sales_by_region_query <- "
SELECT 
    Region,
    SUM(TotalAmount) as TotalSales,
    COUNT(*) as OrderCount,
    AVG(TotalAmount) as AvgOrderValue
FROM Sales 
WHERE SaleDate >= DATEADD(MONTH, -12, GETDATE())
    AND Region IS NOT NULL
GROUP BY Region
ORDER BY TotalSales DESC
"

# Get data
cat("📊 Fetching sales data...\n")
monthly_sales <- dbGetQuery(con, sales_by_month_query)
top_customers <- dbGetQuery(con, top_customers_query)
top_products <- dbGetQuery(con, top_products_query)
sales_by_region <- dbGetQuery(con, sales_by_region_query)

# Close connection
dbDisconnect(con)

# Chart 1: Monthly Sales Trend
sales_chart <- ggplot(monthly_sales, aes(x = reorder(MonthYear, paste(Year, sprintf('%02d', Month))), y = TotalSales)) +
  geom_col(fill = "steelblue", alpha = 0.8) +
  geom_line(aes(group = 1), color = "red", size = 1.2) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Monthly Sales - Last 12 Months", x = "Month", y = "Sales") +
  scale_y_continuous(labels = dollar_format())

# Chart 2: Top 10 Customers
customers_chart <- ggplot(top_customers, aes(x = reorder(CustomerName, TotalPurchases), y = TotalPurchases)) +
  geom_col(fill = "forestgreen", alpha = 0.8) +
  coord_flip() +
  theme_minimal() +
  labs(title = "Top 10 Customers", x = "Customer", y = "Total Purchases") +
  scale_y_continuous(labels = dollar_format())

# Chart 3: Top 10 Products
products_chart <- ggplot(top_products, aes(x = reorder(ProductName, TotalRevenue), y = TotalRevenue)) +
  geom_col(fill = "orange", alpha = 0.8) +
  coord_flip() +
  theme_minimal() +
  labs(title = "Top 10 Products by Revenue", x = "Product", y = "Total Revenue") +
  scale_y_continuous(labels = dollar_format())

# Chart 4: Sales by Region
region_chart <- ggplot(sales_by_region, aes(x = reorder(Region, TotalSales), y = TotalSales)) +
  geom_col(fill = "purple", alpha = 0.8) +
  coord_flip() +
  theme_minimal() +
  labs(title = "Sales by Region", x = "Region", y = "Total Sales") +
  scale_y_continuous(labels = dollar_format())

# Convert to interactive charts
interactive_sales <- ggplotly(sales_chart)
interactive_customers <- ggplotly(customers_chart)
interactive_products <- ggplotly(products_chart)
interactive_regions <- ggplotly(region_chart)

# Save charts
htmlwidgets::saveWidget(interactive_sales, "monthly_sales.html", selfcontained = TRUE)
htmlwidgets::saveWidget(interactive_customers, "top_customers.html", selfcontained = TRUE)
htmlwidgets::saveWidget(interactive_products, "top_products.html", selfcontained = TRUE)
htmlwidgets::saveWidget(interactive_regions, "sales_by_region.html", selfcontained = TRUE)

# Print summary
cat("\n📈 SALES SUMMARY:\n")
cat("Total Sales (12 months):", dollar(sum(monthly_sales$TotalSales)), "\n")
cat("Best Month:", monthly_sales$MonthYear[which.max(monthly_sales$TotalSales)], "\n")
cat("Top Customer:", top_customers$CustomerName[1], "(", top_customers$City[1], ",", top_customers$Country[1], ")\n")
cat("Top Product:", top_products$ProductName[1], "(", top_products$Category[1], ")\n")
cat("Best Region:", sales_by_region$Region[1], "\n")
cat("\n✅ Charts saved: monthly_sales.html, top_customers.html, top_products.html, sales_by_region.html\n")
