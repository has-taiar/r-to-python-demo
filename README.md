# R Sales Analytics Project

This project provides R scripts and notebooks to analyze sales data from SQL Server Express, creating interactive HTML visualizations for:

- Monthly sales trends over 12 months
- Top 10 customers analysis

## 🚀 Quick Start

### 1. Development Container Setup

This project includes a complete development container with Ubuntu OS and all R dependencies pre-installed.

**To use the dev container:**
1. Install Docker Desktop and VS Code with Dev Containers extension
2. Open this folder in VS Code
3. Click "Reopen in Container" when prompted
4. Wait for the container to build (first time only)

### 2. Configure Database Connection

1. Copy `config_template.R` to `config.R`
2. Update the database details in `config.R`:
   - Server name (usually `localhost\SQLEXPRESS`)
   - Database name
   - Table and column names
   - Authentication method

### 3. Run the Analysis

**Option A: R Script**
```r
source("sales_analysis.R")
```

**Option B: R Markdown (Recommended)**
```r
rmarkdown::render("sales_analysis.Rmd")
```

## 📁 Project Structure

```
├── .devcontainer/
│   ├── devcontainer.json    # Dev container configuration
│   └── setup.sh            # R packages and dependencies setup
├── sales_analysis.R         # Main R script
├── sales_analysis.Rmd       # R Markdown notebook
├── config_template.R        # Database configuration template
└── README.md               # This file
```

## 🔧 Dependencies Included

The dev container automatically installs:
- **Database**: DBI, odbc, RODBC
- **Data Processing**: dplyr, lubridate
- **Visualization**: ggplot2, plotly, htmlwidgets
- **Reporting**: rmarkdown, knitr, DT
- **System**: ODBC drivers for SQL Server

## 📊 Output Files

The scripts generate interactive HTML files:
- `monthly_sales_chart.html` - Monthly sales trend
- `top_customers_chart.html` - Top 10 customers
- `sales_dashboard.html` - Combined dashboard
- `sales_analysis.html` - Full R Markdown report

## 🗃️ Database Requirements

Your SQL Server database should have tables similar to:

**Orders Table:**
- OrderID (int, primary key)
- CustomerID (int, foreign key)  
- OrderDate (datetime)
- TotalAmount (decimal/money)

**Customers Table:**
- CustomerID (int, primary key)
- CustomerName (varchar)

Update the SQL queries in the scripts to match your actual table structure.

## 🐳 Container Features

- Ubuntu-based environment
- R with tidyverse pre-installed
- SQL Server ODBC drivers
- VS Code R extensions
- All necessary system dependencies

## 🚨 Troubleshooting

**Connection Issues:**
1. Verify SQL Server Express is running
2. Check Windows Authentication vs SQL Auth
3. Ensure database/table names are correct
4. Test connection outside of R first

**Container Issues:**
1. Rebuild container if needed
2. Check Docker Desktop is running
3. Ensure sufficient disk space

This is a demo to show how an R script or notebook can be migrated to python easily. 
