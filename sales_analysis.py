# Simple Sales Analytics Dashboard
# Creates visualizations for FinancialReportingDemo database

# Load libraries
import pyodbc
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import plotly.offline as pyo

# Database connection parameters
DB_CONFIG = {
    'server': 'localhost\\SQLEXPRESS',
    'database': 'FinancialReportingDemo',  # Updated to match create_database.sql
    'driver': 'ODBC Driver 17 for SQL Server',
    'trusted_connection': 'yes'
}

# Create connection string
connection_string = f"Driver={{{DB_CONFIG['driver']}}};Server={DB_CONFIG['server']};Database={DB_CONFIG['database']};Trusted_Connection={DB_CONFIG['trusted_connection']};"

# Database connection
conn = pyodbc.connect(connection_string)
print(f"✅ Connected to {DB_CONFIG['database']} database")

# SQL Queries - Based on actual database schema
sales_by_month_query = """
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
"""

top_customers_query = """
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
"""

top_products_query = """
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
"""

sales_by_region_query = """
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
"""

# Get data
print("📊 Fetching sales data...")
monthly_sales = pd.read_sql(sales_by_month_query, conn)
top_customers = pd.read_sql(top_customers_query, conn)
top_products = pd.read_sql(top_products_query, conn)
sales_by_region = pd.read_sql(sales_by_region_query, conn)

# Close connection
conn.close()

# Helper function to format currency
def format_currency(value):
    return f"${value:,.2f}"

# Chart 1: Monthly Sales Trend
# Create month order for proper sorting
monthly_sales['month_order'] = monthly_sales['Year'] * 100 + monthly_sales['Month']
monthly_sales = monthly_sales.sort_values('month_order')

sales_chart = go.Figure()
sales_chart.add_trace(go.Bar(
    x=monthly_sales['MonthYear'],
    y=monthly_sales['TotalSales'],
    name='Sales',
    marker_color='steelblue',
    opacity=0.8
))
sales_chart.add_trace(go.Scatter(
    x=monthly_sales['MonthYear'],
    y=monthly_sales['TotalSales'],
    mode='lines+markers',
    name='Trend',
    line=dict(color='red', width=3),
    marker=dict(size=8)
))
sales_chart.update_layout(
    title='Monthly Sales - Last 12 Months',
    xaxis_title='Month',
    yaxis_title='Sales',
    template='plotly_white',
    xaxis_tickangle=-45,
    yaxis_tickformat='$,.0f'
)

# Chart 2: Top 10 Customers
customers_chart = px.bar(
    top_customers,
    x='TotalPurchases',
    y='CustomerName',
    orientation='h',
    title='Top 10 Customers',
    labels={'TotalPurchases': 'Total Purchases', 'CustomerName': 'Customer'},
    color_discrete_sequence=['forestgreen']
)
customers_chart.update_layout(template='plotly_white', xaxis_tickformat='$,.0f')

# Chart 3: Top 10 Products
products_chart = px.bar(
    top_products,
    x='TotalRevenue',
    y='ProductName',
    orientation='h',
    title='Top 10 Products by Revenue',
    labels={'TotalRevenue': 'Total Revenue', 'ProductName': 'Product'},
    color_discrete_sequence=['orange']
)
products_chart.update_layout(template='plotly_white', xaxis_tickformat='$,.0f')

# Chart 4: Sales by Region
region_chart = px.bar(
    sales_by_region,
    x='TotalSales',
    y='Region',
    orientation='h',
    title='Sales by Region',
    labels={'TotalSales': 'Total Sales', 'Region': 'Region'},
    color_discrete_sequence=['purple']
)
region_chart.update_layout(template='plotly_white', xaxis_tickformat='$,.0f')

# Save charts
pyo.plot(sales_chart, filename='monthly_sales.html', auto_open=False)
pyo.plot(customers_chart, filename='top_customers.html', auto_open=False)
pyo.plot(products_chart, filename='top_products.html', auto_open=False)
pyo.plot(region_chart, filename='sales_by_region.html', auto_open=False)

# Print summary
print("\n📈 SALES SUMMARY:")
print(f"Total Sales (12 months): {format_currency(monthly_sales['TotalSales'].sum())}")
best_month = monthly_sales.loc[monthly_sales['TotalSales'].idxmax(), 'MonthYear']
print(f"Best Month: {best_month}")
print(f"Top Customer: {top_customers.iloc[0]['CustomerName']} ({top_customers.iloc[0]['City']}, {top_customers.iloc[0]['Country']})")
print(f"Top Product: {top_products.iloc[0]['ProductName']} ({top_products.iloc[0]['Category']})")
print(f"Best Region: {sales_by_region.iloc[0]['Region']}")
print("\n✅ Charts saved: monthly_sales.html, top_customers.html, top_products.html, sales_by_region.html")
