# R to Python Sales Analytics Migration Demo

This project demonstrates migrating R scripts to Python for sales data analysis from SQL Server, creating identical interactive HTML visualizations for:

- Monthly sales trends over 12 months
- Top 10 customers analysis
- Sales by Region
- and other common sales queries 

To run the R script locally (in PowerShell): 
cd \R_solution
& "C:\Program Files\R\R-4.5.1\bin\Rscript.exe" sales_analysis.R

## 🚀 Quick Start

### Test migration from R to Python
Use the prompt below to test the migration
```
I have this sales_analysis.R script that I want you to help me migrate it into python. I want the new file to be named r2py.py and I want it to be as simple as possible and it should be identical to the R script and produces the same output. I already have a requirements.txt file so you can update it if needed
```

### 1. Environment Setup

**Option A: Development Container (R)**
1. Install R and its packages
2. Ensure you have the database created locally or point to the Azure SQL (ask Has Altaiar for credentials)
2. Run the R script locally -> An example sales_dashboard.html file is included in this repo

### 2. Configure Database Connection

1. The script is configured to use local SQL on SQLExpress server (the database creation sql is included)
2. If using the Azure SQL, then you can create a .env or setup the credentials directly in powershell 
1. Copy `.env.example` to `.env` and update with your credentials
2. Or set environment variables directly:

**Windows PowerShell:**
```powershell
$env:DB_USERNAME = "your_username"
$env:DB_PASSWORD = "your_password"
```
