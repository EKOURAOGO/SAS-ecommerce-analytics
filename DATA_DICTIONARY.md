# Data Dictionary - E-Commerce Dataset

## Overview
Complete variable definitions for the Global E-Commerce Dataset (1M+ records, 2024-2026)

## Dataset Variables

### Primary Keys
- `order_id`: Unique order identifier (numeric)
- `customer_id`: Customer unique identifier (character)

### Temporal Variables
- `order_date`: Purchase transaction date (DDMMYY10)
- `month`: Month of transaction (1-12)
- `quarter`: Quarter of year (1-4)
- `year`: Year (YYYY)

### Transaction Data
- `product_price`: Unit price USD ($0-$5000)
- `quantity`: Units purchased (1-100)
- `order_value`: Total transaction value ($0-$500K)
- `product_category`: Product classification (50 levels)

### Customer Demographics
- `customer_age`: Customer age (18-80)
- `region`: Geographic location (5 levels)
- `unemployment_rate`: Regional unemployment rate (3-10%)

### Business Metrics (Derived)
- `customer_lifetime_value`: Total customer spending
- `purchase_frequency`: Number of transactions per customer
- `days_since_last_purchase`: Recency (RFM analysis)

### Model Target & Features
- `churn`: Target variable (1=Churned >180 days, 0=Retained)
- `log_clv`: Log-transformed customer lifetime value
- `recency`: Days since last purchase
- `frequency`: Purchase count
- `monetary`: Average order value

## Summary Statistics
- Total Records: 1,000,000+
- Date Range: 2024-2026 (24 months)
- Avg Order Value: $125
- Avg Customer Age: 42 years
- Churn Rate: 9.9%
- Retention Rate: 90.1%

---

**Status:** Complete | **Updated:** July 2026
