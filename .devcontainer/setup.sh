#!/bin/bash

set -e  # Exit on any error

echo "🚀 Starting R development environment setup..."

# Update package lists
echo "📦 Updating package lists..."
sudo apt-get update

# Install basic system dependencies
echo "🔧 Installing system dependencies..."
sudo apt-get install -y \
    curl \
    wget \
    gnupg \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    unixodbc \
    unixodbc-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev

# Install additional R package dependencies
echo "🔗 Installing R package dependencies..."
sudo apt-get install -y \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev

# Try to install Microsoft ODBC Driver (optional, don't fail if it doesn't work)
echo "🗃️ Attempting to install Microsoft ODBC Driver..."
{
    # Add Microsoft repository
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/ubuntu/$(lsb_release -rs)/prod $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mssql-release.list
    
    sudo apt-get update
    sudo ACCEPT_EULA=Y apt-get install -y msodbcsql17 || echo "⚠️ Microsoft ODBC Driver installation failed - continuing anyway"
} || echo "⚠️ Microsoft repositories not available - continuing with basic setup"

# Install essential R packages
echo "📊 Installing R packages..."
R -e "
cat('Installing essential R packages...\n')
packages <- c(
  'DBI',
  'odbc', 
  'dplyr',
  'ggplot2',
  'plotly',
  'htmlwidgets',
  'lubridate',
  'scales',
  'htmltools',
  'knitr',
  'rmarkdown',
  'DT'
)

for (pkg in packages) {
  cat('Installing:', pkg, '\n')
  tryCatch({
    install.packages(pkg, repos='https://cran.rstudio.com/', dependencies=TRUE, quiet=TRUE)
    cat('✅ Successfully installed:', pkg, '\n')
  }, error = function(e) {
    cat('❌ Failed to install:', pkg, '- Error:', conditionMessage(e), '\n')
  })
}

cat('✅ R package installation complete!\n')
"

echo "✅ R development environment setup complete!"
echo ""
echo "🎯 What's available:"
echo "   • R with tidyverse pre-installed"
echo "   • Database connectivity packages (DBI, odbc)"
echo "   • Visualization packages (ggplot2, plotly)"
echo "   • Report generation (rmarkdown, knitr)"
echo ""
echo "📋 Next steps:"
echo "   1. Configure your database connection in config.R"
echo "   2. Run your R scripts or R Markdown notebooks"
echo "   3. Create beautiful visualizations!"
