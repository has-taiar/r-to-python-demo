# Simple Sales Analytics Dashboard - Python Migration from R
# Creates a single HTML page with all visualizations

# Load libraries
import pyodbc
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import plotly.offline as pyo
import os
from datetime import datetime

# Database Configuration (equivalent to config.R)
DB_CONFIG = {
    'server': 'localhost\\SQLEXPRESS',
    'database': 'FinancialReportingDemo',
    'use_windows_auth': True,
    'username': os.getenv('DB_USERNAME', ''),
    'password': os.getenv('DB_PASSWORD', ''),
    'timeout': 30
}

# Sample queries (equivalent to SAMPLE_QUERIES in config.R)
SAMPLE_QUERIES = {
    'sales_query': """
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
    """,
    
    'customers_query': """
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
    """
}

# Validate configuration
if not DB_CONFIG['use_windows_auth'] and (not DB_CONFIG['username'] or not DB_CONFIG['password']):
    print("❌ Error: Database credentials not found in environment variables!")
    print("📝 Please set the following environment variables:")
    print("   Windows PowerShell:")
    print("     $env:DB_USERNAME = \"your_username\"")
    print("     $env:DB_PASSWORD = \"your_password\"")
    exit(1)

print("✅ Database configuration loaded successfully!")
print(f"🔗 Server: {DB_CONFIG['server']}")
print(f"🗃️  Database: {DB_CONFIG['database']}")
print(f"👤 Username: {DB_CONFIG['username']}")

# Connect to database
if DB_CONFIG['use_windows_auth']:
    connection_string = (
        f"Driver={{ODBC Driver 17 for SQL Server}};"
        f"Server={DB_CONFIG['server']};"
        f"Database={DB_CONFIG['database']};"
        f"Trusted_Connection=yes;"
    )
else:
    connection_string = (
        f"Driver={{ODBC Driver 17 for SQL Server}};"
        f"Server={DB_CONFIG['server']};"
        f"Database={DB_CONFIG['database']};"
        f"UID={DB_CONFIG['username']};"
        f"PWD={DB_CONFIG['password']};"
    )

conn = pyodbc.connect(connection_string)
print(f"✅ Connected to {DB_CONFIG['database']} database")

# Define queries (same as R script)
monthly_sales_query = SAMPLE_QUERIES['sales_query']
top_customers_query = SAMPLE_QUERIES['customers_query']

# Simplified queries for initial testing (same as R script)
top_products_query = """
SELECT TOP 10
    'Product ' + CAST(ROW_NUMBER() OVER(ORDER BY NEWID()) AS VARCHAR(10)) as ProductName,
    'Category A' as Category,
    CAST(RAND() * 50000 + 10000 AS DECIMAL(10,2)) as TotalRevenue,
    CAST(RAND() * 1000 + 100 AS INT) as TotalQuantity
"""

sales_by_region_query = """
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
"""

# Fetch all data
print("📊 Fetching sales data...")
monthly_sales = pd.read_sql(monthly_sales_query, conn)
top_customers = pd.read_sql(top_customers_query, conn)
top_products = pd.read_sql(top_products_query, conn)
sales_by_region = pd.read_sql(sales_by_region_query, conn)
conn.close()

# Helper function to format currency
def format_currency(value):
    return f"${value:,.0f}"

# Create charts (equivalent to ggplot charts in R)
# 1. Monthly Sales Trend
monthly_sales_sorted = monthly_sales.sort_values(['Year', 'Month'])
fig1 = go.Figure()
fig1.add_trace(go.Bar(
    x=monthly_sales_sorted['MonthYear'],
    y=monthly_sales_sorted['TotalSales'],
    name='Sales',
    marker_color='steelblue',
    opacity=0.8
))
fig1.add_trace(go.Scatter(
    x=monthly_sales_sorted['MonthYear'],
    y=monthly_sales_sorted['TotalSales'],
    mode='lines',
    name='Trend',
    line=dict(color='red', width=3)
))
fig1.update_layout(
    title='Monthly Sales Trend',
    xaxis_title='Month',
    yaxis_title='Sales',
    template='plotly_white',
    xaxis_tickangle=45
)
fig1.update_yaxes(tickformat='$,.0f')

# 2. Top Customers
top_customers_sorted = top_customers.sort_values('TotalPurchases')
fig2 = go.Figure(go.Bar(
    x=top_customers_sorted['TotalPurchases'],
    y=top_customers_sorted['CustomerName'],
    orientation='h',
    marker_color='forestgreen',
    opacity=0.8
))
fig2.update_layout(
    title='Top 10 Customers',
    xaxis_title='Total Purchases',
    yaxis_title='Customer',
    template='plotly_white'
)
fig2.update_xaxes(tickformat='$,.0f')

# 3. Top Products
top_products_sorted = top_products.sort_values('TotalRevenue')
fig3 = go.Figure(go.Bar(
    x=top_products_sorted['TotalRevenue'],
    y=top_products_sorted['ProductName'],
    orientation='h',
    marker_color='orange',
    opacity=0.8
))
fig3.update_layout(
    title='Top 10 Products',
    xaxis_title='Revenue',
    yaxis_title='Product',
    template='plotly_white'
)
fig3.update_xaxes(tickformat='$,.0f')

# 4. Sales by Region
sales_by_region_sorted = sales_by_region.sort_values('TotalSales')
fig4 = go.Figure(go.Bar(
    x=sales_by_region_sorted['TotalSales'],
    y=sales_by_region_sorted['Region'],
    orientation='h',
    marker_color='purple',
    opacity=0.8
))
fig4.update_layout(
    title='Sales by Region',
    xaxis_title='Total Sales',
    yaxis_title='Region',
    template='plotly_white'
)
fig4.update_xaxes(tickformat='$,.0f')

# Calculate summary statistics (same as R script)
total_sales = monthly_sales['TotalSales'].sum()
best_month = monthly_sales.loc[monthly_sales['TotalSales'].idxmax(), 'MonthYear']
top_customer = top_customers.iloc[0]['CustomerName']
top_product = top_products.iloc[0]['ProductName']
best_region = sales_by_region.iloc[0]['Region']

# Create combined dashboard (equivalent to R's htmltools)
from plotly.subplots import make_subplots

# Create a dashboard with all 4 charts
dashboard_fig = make_subplots(
    rows=2, cols=2,
    subplot_titles=('Monthly Sales Trend', 'Top 10 Customers', 'Top 10 Products', 'Sales by Region'),
    specs=[[{"secondary_y": False}, {"secondary_y": False}],
           [{"secondary_y": False}, {"secondary_y": False}]],
    vertical_spacing=0.15,
    horizontal_spacing=0.1
)

# Add traces to subplots
# Chart 1: Monthly Sales (top-left)
dashboard_fig.add_trace(
    go.Bar(x=monthly_sales_sorted['MonthYear'], y=monthly_sales_sorted['TotalSales'], 
           name='Sales', marker_color='steelblue', opacity=0.8, showlegend=False),
    row=1, col=1
)
dashboard_fig.add_trace(
    go.Scatter(x=monthly_sales_sorted['MonthYear'], y=monthly_sales_sorted['TotalSales'],
               mode='lines', name='Trend', line=dict(color='red', width=2), showlegend=False),
    row=1, col=1
)

# Chart 2: Top Customers (top-right)
dashboard_fig.add_trace(
    go.Bar(x=top_customers_sorted['TotalPurchases'], y=top_customers_sorted['CustomerName'],
           orientation='h', marker_color='forestgreen', opacity=0.8, showlegend=False),
    row=1, col=2
)

# Chart 3: Top Products (bottom-left)
dashboard_fig.add_trace(
    go.Bar(x=top_products_sorted['TotalRevenue'], y=top_products_sorted['ProductName'],
           orientation='h', marker_color='orange', opacity=0.8, showlegend=False),
    row=2, col=1
)

# Chart 4: Sales by Region (bottom-right)
dashboard_fig.add_trace(
    go.Bar(x=sales_by_region_sorted['TotalSales'], y=sales_by_region_sorted['Region'],
           orientation='h', marker_color='purple', opacity=0.8, showlegend=False),
    row=2, col=2
)

# Update layout
dashboard_fig.update_layout(
    title_text=f"Sales Analytics Dashboard - {DB_CONFIG['database']}",
    title_x=0.5,
    height=800,
    template='plotly_white',
    font=dict(family="Arial", size=10)
)

# Format axes
dashboard_fig.update_xaxes(tickformat='$,.0f', row=1, col=1)
dashboard_fig.update_xaxes(tickformat='$,.0f', row=1, col=2)
dashboard_fig.update_xaxes(tickformat='$,.0f', row=2, col=1)
dashboard_fig.update_xaxes(tickformat='$,.0f', row=2, col=2)

# Rotate x-axis labels for monthly sales
dashboard_fig.update_xaxes(tickangle=45, row=1, col=1)

# Save the dashboard (equivalent to save_html in R)
# Use Plotly's to_html method to create a simple dashboard similar to R's output
dashboard_html = dashboard_fig.to_html(
    include_plotlyjs='cdn',
    config={'displayModeBar': True, 'responsive': True}
)

# Add summary statistics to the HTML
summary_section = f"""
<div style="font-family: Arial, sans-serif; margin: 20px; padding: 20px; background-color: #f8f9fa; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
    <h3>📈 Key Performance Indicators</h3>
    <div style="display: flex; flex-wrap: wrap; gap: 20px;">
        <div><strong>Total Sales:</strong> {format_currency(total_sales)}</div>
        <div><strong>Best Month:</strong> {best_month}</div>
        <div><strong>Top Customer:</strong> {top_customer}</div>
        <div><strong>Top Product:</strong> {top_product}</div>
        <div><strong>Best Region:</strong> {best_region}</div>
    </div>
</div>
"""

# Insert summary before the plotly div
final_html = dashboard_html.replace(
    '<body>',
    f'<body>{summary_section}'
)

# Add footer
footer_section = f"""
<div style="text-align: center; color: #666; margin-top: 30px; font-family: Arial, sans-serif;">
    <p>Report generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
    <p>Data source: FinancialReportingDemo Database</p>
</div>
"""

final_html = final_html.replace('</body>', f'{footer_section}</body>')

with open('sales_dashboard.html', 'w', encoding='utf-8') as f:
    f.write(final_html)

# Print completion message (same as R script)
print("\n✅ Dashboard created successfully!")
print("📊 Open 'sales_dashboard.html' to view all charts in one page")
print("\n📈 Summary:")
print(f"Total Sales: {format_currency(total_sales)}")
print(f"Best Month: {best_month}")
print(f"Top Customer: {top_customer}")
