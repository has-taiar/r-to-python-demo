# R to Python Sales Analytics Migration Demo

This project demonstrates migrating R scripts to Python for sales data analysis from SQL Server, creating identical interactive HTML visualizations for:

- Monthly sales trends over 12 months
- Top 10 customers analysis

To run the R script: 
& "C:\Program Files\R\R-4.5.1\bin\Rscript.exe" sales_analysis.R

## 🚀 Quick Start

### 1. Environment Setup

**Option A: Development Container (R)**
1. Install Docker Desktop and VS Code with Dev Containers extension
2. Open this folder in VS Code
3. Click "Reopen in Container" when prompted
4. Wait for the container to build (first time only)

**Option B: Local Python**
```bash
pip install pyodbc pandas plotly
```

### 2. Configure Database Connection

1. Copy `.env.example` to `.env` and update with your credentials
2. Or set environment variables directly:

**Windows PowerShell:**
```powershell
$env:DB_USERNAME = "your_username"
$env:DB_PASSWORD = "your_password"
```

**Quick Setup Script:**
```powershell
.\set-env.ps1
```

**Linux/Mac:**
```bash
export DB_USERNAME=your_username
export DB_PASSWORD=your_password
```

### 3. Run the Analysis

**Option A: R Script**
```r
source("R_solution/sales_analysis.R")
```

**Option B: Python Script**
```python
python sales_analysis.py
```

**Option C: R Markdown (R only)**
```r
rmarkdown::render("R_solution/sales_analysis.Rmd")
```

## 📁 Project Structure

```
├── .devcontainer/
│   ├── devcontainer.json    # Dev container configuration
│   └── setup.sh            # R packages and dependencies setup
├── R_solution/
│   ├── sales_analysis.R     # Main R script
│   ├── sales_analysis.Rmd   # R Markdown notebook
│   └── config.R            # R database configuration
├── sales_analysis.py        # Python equivalent script
├── .env.example            # Environment variables template
├── set-env.ps1             # PowerShell setup script
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
