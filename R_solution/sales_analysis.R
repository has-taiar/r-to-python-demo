# Simple Sales Analytics Dashboard
# Creates a single HTML page with all visualizations

# Load libraries
library(DBI)
library(odbc)
library(ggplot2)
library(plotly)
library(htmlwidgets)
library(htmltools)
library(scales)

# Load configuration with environment variables
source("config.R")

# Connect to database
if (DB_CONFIG$use_windows_auth) {
  connection_string <- paste0(
    "Driver={", "ODBC Driver 17 for SQL Server", "};",
    "Server=", DB_CONFIG$server, ";",
    "Database=", DB_CONFIG$database, ";",
    "Trusted_Connection=yes;"
  )
} else {
  connection_string <- paste0(
    "Driver={", "ODBC Driver 17 for SQL Server", "};",
    "Server=", DB_CONFIG$server, ";",
    "Database=", DB_CONFIG$database, ";",
    "UID=", DB_CONFIG$username, ";",
    "PWD=", DB_CONFIG$password, ";"
  )
}

con <- dbConnect(odbc::odbc(), .connection_string = connection_string)
cat("✅ Connected to", DB_CONFIG$database, "database\n")

# Use the queries from config.R for consistency
monthly_sales_query <- SAMPLE_QUERIES$sales_query

top_customers_query <- SAMPLE_QUERIES$customers_query

# Simplified queries for initial testing
top_products_query <- "
SELECT TOP 10
    'Product ' + CAST(ROW_NUMBER() OVER(ORDER BY NEWID()) AS VARCHAR(10)) as ProductName,
    'Category A' as Category,
    CAST(RAND() * 50000 + 10000 AS DECIMAL(10,2)) as TotalRevenue,
    CAST(RAND() * 1000 + 100 AS INT) as TotalQuantity
"

sales_by_region_query <- "
SELECT 
    Region,
    SUM(TotalAmount) as TotalSales,
    COUNT(*) as OrderCount
FROM (
    SELECT 'North' as Region, 25000.00 as TotalAmount, 1 as OrderID
    UNION ALL SELECT 'South', 18000.00, 2
    UNION ALL SELECT 'East', 32000.00, 3
    UNION ALL SELECT 'West', 28000.00, 4
) as RegionData
GROUP BY Region
ORDER BY TotalSales DESC
"

# Fetch all data
cat("📊 Fetching sales data...\n")
monthly_sales <- dbGetQuery(con, monthly_sales_query)
top_customers <- dbGetQuery(con, top_customers_query)
top_products <- dbGetQuery(con, top_products_query)
sales_by_region <- dbGetQuery(con, sales_by_region_query)
dbDisconnect(con)

# Create charts
# 1. Monthly Sales Trend
chart1 <- ggplot(monthly_sales, aes(x = reorder(MonthYear, paste(Year, sprintf('%02d', Month))), y = TotalSales)) +
  geom_col(fill = "steelblue", alpha = 0.8) +
  geom_line(aes(group = 1), color = "red", size = 1.2) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Monthly Sales Trend", x = "Month", y = "Sales") +
  scale_y_continuous(labels = dollar_format())

# 2. Top Customers
chart2 <- ggplot(top_customers, aes(x = reorder(CustomerName, TotalPurchases), y = TotalPurchases)) +
  geom_col(fill = "forestgreen", alpha = 0.8) +
  coord_flip() +
  theme_minimal() +
  labs(title = "Top 10 Customers", x = "Customer", y = "Total Purchases") +
  scale_y_continuous(labels = dollar_format())

# 3. Top Products
chart3 <- ggplot(top_products, aes(x = reorder(ProductName, TotalRevenue), y = TotalRevenue)) +
  geom_col(fill = "orange", alpha = 0.8) +
  coord_flip() +
  theme_minimal() +
  labs(title = "Top 10 Products", x = "Product", y = "Revenue") +
  scale_y_continuous(labels = dollar_format())

# 4. Sales by Region
chart4 <- ggplot(sales_by_region, aes(x = reorder(Region, TotalSales), y = TotalSales)) +
  geom_col(fill = "purple", alpha = 0.8) +
  coord_flip() +
  theme_minimal() +
  labs(title = "Sales by Region", x = "Region", y = "Total Sales") +
  scale_y_continuous(labels = dollar_format())

# Convert to interactive plots
plot1 <- ggplotly(chart1)
plot2 <- ggplotly(chart2)
plot3 <- ggplotly(chart3)
plot4 <- ggplotly(chart4)

# Calculate summary statistics
total_sales <- sum(monthly_sales$TotalSales)
best_month <- monthly_sales$MonthYear[which.max(monthly_sales$TotalSales)]
top_customer <- top_customers$CustomerName[1]
top_product <- top_products$ProductName[1]
best_region <- sales_by_region$Region[1]

# Create combined HTML dashboard
dashboard <- tagList(
  tags$head(
    tags$title("Sales Analytics Dashboard"),
    tags$style(HTML("
      body { font-family: Arial, sans-serif; margin: 20px; background-color: #f8f9fa; }
      .header { text-align: center; color: #333; margin-bottom: 30px; }
      .summary { background: white; padding: 20px; border-radius: 8px; margin-bottom: 30px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
      .chart-container { background: white; padding: 15px; margin-bottom: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
      .summary-item { display: inline-block; margin: 10px 20px; }
      .footer { text-align: center; color: #666; margin-top: 30px; }
    "))
  ),
  
  div(class = "header",
    h1("Sales Analytics Dashboard"),
    h3(paste("Financial Analysis for", DB_CONFIG$database))
  ),
  
  div(class = "summary",
    h3("📈 Key Performance Indicators"),
    div(class = "summary-item", strong("Total Sales: "), dollar(total_sales)),
    div(class = "summary-item", strong("Best Month: "), best_month),
    div(class = "summary-item", strong("Top Customer: "), top_customer),
    div(class = "summary-item", strong("Top Product: "), top_product),
    div(class = "summary-item", strong("Best Region: "), best_region)
  ),
  
  div(class = "chart-container", plot1),
  div(class = "chart-container", plot2),
  div(class = "chart-container", plot3),
  div(class = "chart-container", plot4),
  
  div(class = "footer",
    p(paste("Report generated on", Sys.time())),
    p("Data source: FinancialReportingDemo Database")
  )
)

# Save the dashboard
save_html(dashboard, "sales_dashboard.html")

# Print completion message
cat("\n✅ Dashboard created successfully!\n")
cat("📊 Open 'sales_dashboard.html' to view all charts in one page\n")
cat("\n📈 Summary:\n")
cat("Total Sales:", dollar(total_sales), "\n")
cat("Best Month:", best_month, "\n")
cat("Top Customer:", top_customer, "\n")
