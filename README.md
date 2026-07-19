# SAS E-Commerce Analytics: Predictive Customer Intelligence

> Enterprise-grade SAS analytics platform for e-commerce customer segmentation, churn prediction, and business intelligence

##  Project Overview

Advanced SAS-based analytics system analyzing 1M+ e-commerce transactions for customer behavior prediction, lifetime value modeling, and retention strategy optimization. Production-ready code with enterprise governance and compliance standards.

**Key Deliverables:**
- Predictive churn model (logistic regression with PROC LOGISTIC)
- Customer segmentation & RFM analysis
- Revenue forecasting & trend analysis
- Automated reporting pipeline
- Data quality assessment framework

##  Dataset

**Source:** Kaggle Global E-Commerce Dataset (February 2026)

**Specifications:**
- **Volume:** 1,000,000+ transactions
- **Scope:** Multi-channel e-commerce sales data (2024-2026)
- **Granularity:** Transaction-level with customer demographics

**Key Variables:**
- `order_id`  Unique transaction identifier
- `customer_id`  Customer primary key
- `order_date`  Transaction timestamp
- `product_category`  Category classification
- `product_price`  Unit price (USD)
- `quantity`  Units purchased
- `order_value`  Total transaction value
- `return_status`  Return indicator
- `customer_age`  Customer demographics
- `region`  Geographic location

**Data Dimensions:**
- Customers: 100K+
- Products: 50+ categories
- Geographic regions: 150+
- Time period: 24 months

##  Project Architecture

```
sas-ecommerce-analytics/
 programs/
    main_analysis.sas            Primary analysis workflow
    config.sas                   Global settings & macros
    utility_macros.sas           Reusable SAS macros
    quality_checks.sas           Data quality validation
    exploratory_analysis.sas     EDA & visualization
    predictive_models.sas        Churn & revenue models
    export_results.sas           Output generation
    generate_reports.sas         Automated reporting

 data/
    ecommerce_raw.csv            Raw 1M transactions
    processed/                   Intermediate datasets

 output/
    reports/                     RTF reports
    datasets/                    CSV exports
    graphics/                    ODS output
    logs/                        Execution logs

 config/
    parameters.txt               Configuration parameters

 docs/
    data_dictionary.md           Variable definitions
    methodology.md               Analysis approach
    technical_guide.md           Implementation guide

 README.md (this file)
```

##  Quick Start

### Prerequisites

**SAS Installation Options:**
1. **SAS Viya** (Cloud-based, free trial)
   - URL: https://www.sas.com/en_us/software/viya/viya-cloud-trial.html
   - Duration: 30-day trial
   
2. **SAS University Edition** (Free for students/academics)
   - Download: https://www.sas.com/en_us/software/university-edition/download-software.html
   - Platform: Windows, Mac, Linux
   
3. **SAS Studio Online** (Web-based, free trial)
   - Access: https://www.sas.com/en_us/software/studio/studio-online.html

### Installation & Setup

```bash
# 1. Clone repository
git clone https://github.com/EKOURAOGO/sas-ecommerce-analytics
cd sas-ecommerce-analytics

# 2. Download data from Kaggle
# - Dataset: Global E-Commerce Dataset (+1M Records, 20242026)
# - URL: https://www.kaggle.com/datasets/akrambelha/global-e-commerce-dataset-1m-records-20242026
# - Place in: data/ecommerce_raw.csv

# 3. Update paths in config.sas
# Edit: programs/config.sas
#   %let project_root = /your/path/sas-ecommerce-analytics;

# 4. Run analysis pipeline
# In SAS Studio or SAS Enterprise Guide:
#   %include '/path/to/programs/config.sas';
#   %run_pipeline;
```

### Execution in SAS

```sas
/* Load configuration & macros */
%include '/path/to/programs/config.sas';
%include '/path/to/programs/utility_macros.sas';

/* Execute main analysis */
%include '/path/to/programs/main_analysis.sas';

/* Or run specific components */
%include '/path/to/programs/quality_checks.sas';
%include '/path/to/programs/exploratory_analysis.sas';
%include '/path/to/programs/predictive_models.sas';
```

##  Analysis Components

### 1. Data Import & Quality Assessment

**PROC IMPORT** for CSV ingestion with automatic type detection
- Handles 1M+ rows efficiently
- Automatic compression & indexing
- Data validation & anomaly detection
- Missing value imputation strategies

```sas
proc import datafile="&ecommerce_raw"
    out=work.ecommerce_raw
    dbms=csv replace;
    getnames=yes;
    guessingrows=5000;
run;
```

### 2. Exploratory Data Analysis (EDA)

**Statistical Summaries**
- Descriptive statistics (PROC MEANS)
- Frequency distributions (PROC FREQ)
- Correlation analysis (PROC CORR)
- Outlier detection (IQR method)

**Visualizations**
- Histograms & box plots (PROC UNIVARIATE)
- Scatter plots & trend analysis (PROC SGPLOT)
- Distribution by category (ODS Graphics)

### 3. Customer Segmentation

**RFM Analysis:**
- **Recency:** Days since last purchase
- **Frequency:** Number of transactions
- **Monetary:** Total customer lifetime value

**Segmentation Strategy:**
- Classify customers into Low/Medium/High value segments
- Identify high-risk churn candidates
- Prioritize retention efforts

### 4. Predictive Modeling

**Target Variable:** Customer Churn (no purchase > 180 days)

**Model Type:** Logistic Regression (PROC LOGISTIC)

**Predictors:**
- `log_clv`  Log customer lifetime value
- `recency`  Days since last purchase
- `frequency`  Purchase count
- `monetary`  Average order value

**Model Features:**
- Stepwise variable selection (AIC-based)
- Train/test split: 70% / 30%
- Performance metrics: AUC, Accuracy, Sensitivity, Specificity
- Diagnostics: Collinearity checks, residual analysis

### 5. Automated Reporting

**Report Formats:**
- **RTF:** Publication-ready reports
- **CSV:** Data exports for downstream tools
- **ODS HTML:** Interactive dashboards
- **SAS Datasets:** Archival & reproducibility

**Standard Reports:**
- Executive summary (KPIs, trends)
- Customer segmentation analysis
- Churn prediction results
- Revenue forecasting
- Quality assurance logs

##  Key Outputs

### Data Artifacts
- `customer_metrics.csv`  Aggregated customer-level data
- `churn_predictions.csv`  Predicted churn scores & classifications
- `category_revenue.csv`  Revenue by product category
- `outliers_detected.csv`  Identified anomalies

### Model Artifacts
- Parameter estimates (estimates.txt)
- ROC curve data (roc_curve.csv)
- Model diagnostics (fit_statistics.txt)

### Reports
- `ecommerce_analysis_report.rtf`  Comprehensive analysis
- `executive_summary.html`  Dashboard view
- `quality_assurance_log.txt`  Data validation results
- `execution_summary.log`  Process logs

##  Statistical Methods

### Descriptive Statistics
- **Central Tendency:** Mean, median, mode
- **Dispersion:** Std dev, IQR, range
- **Distribution:** Normality tests (Shapiro-Wilk)

### Inferential Analysis
- **Hypothesis Testing:** T-tests, chi-square
- **ANOVA:** Multi-group comparisons
- **Correlation:** Pearson, Spearman

### Predictive Modeling
- **Logistic Regression:** Binary classification
- **Model Selection:** Stepwise, forward, backward
- **Validation:** Cross-validation, bootstrapping

### Performance Evaluation
- **Accuracy Metrics:** Confusion matrix, accuracy, precision, recall
- **Discrimination:** ROC curve, AUC, Gini coefficient
- **Calibration:** Hosmer-Lemeshow test

##  Business Applications

1. **Customer Retention:**
   - Identify churn-prone customers
   - Prioritize retention campaigns
   - Optimize marketing spend

2. **Revenue Optimization:**
   - Predict customer lifetime value
   - Segment by profitability
   - Upsell/cross-sell strategies

3. **Inventory Management:**
   - Forecast demand by category
   - Optimize stock levels
   - Reduce overstock/stockout

4. **Marketing Strategy:**
   - Personalized targeting
   - Campaign effectiveness measurement
   - ROI optimization

##  Data Governance & Security

**Best Practices:**
- Input validation & sanitization
- Error handling & recovery
- Audit trail logging
- Access control (role-based)
- Data privacy compliance (GDPR)

**SAS Security Features:**
- Encryption at rest & in transit
- Audit logging (PROC AUDIT)
- User authentication integration
- Data masking for sensitive variables

##  Documentation

| Document | Purpose |
|----------|---------|
| `data_dictionary.md` | Variable definitions & data types |
| `methodology.md` | Statistical & analytical methods |
| `technical_guide.md` | Implementation & deployment guide |
| `macro_reference.md` | Utility macro documentation |

##  Testing & Validation

**Quality Assurance:**
- Data completeness checks (missing values)
- Format validation (types, ranges)
- Logical consistency (business rules)
- Performance testing (execution time, memory)

**Regression Testing:**
- Baseline comparisons (output consistency)
- Scenario testing (edge cases)
- Version control (reproducibility)

##  Deployment & Scalability

**Production Readiness:**
- Scheduled batch processing (SAS Scheduler)
- Error notification alerts (email)
- Backup & recovery procedures
- Performance optimization (compression, indexing)

**Scalability:**
- Handles 10M+ observations
- Parallel processing (PROC SORT THREADS)
- Memory-efficient algorithms
- Cloud deployment (SAS Viya)

##  Performance Benchmarks

| Component | Records | Runtime | Memory |
|-----------|---------|---------|--------|
| Data Import | 1M | ~45 sec | 500MB |
| EDA | 1M | ~60 sec | 600MB |
| Modeling | 70% train | ~30 sec | 400MB |
| Report Gen. | All | ~90 sec | 300MB |
| **Total** | **1M** | **~4 min** | **~2GB** |

##  Troubleshooting

### Common Issues

**Issue:** Data file not found
```sas
%put Checking path: &raw_data;
%if %sysfunc(fileexist("&raw_data")) %then %put File exists;
```

**Issue:** Memory exceeded
```sas
options compress=yes memsize=8000M;
proc sort data=large_ds threads=4; run;
```

**Issue:** Invalid variable names
```sas
options validvarname=v7;
proc contents data=work.dataset; run;
```

##  Resources

- **SAS Documentation:** https://support.sas.com/documentation/
- **SAS Community:** https://communities.sas.com/
- **SAS Learning:** https://www.sas.com/en_us/software/sas-training.html
- **Kaggle Dataset:** https://www.kaggle.com/datasets/akrambelha/global-e-commerce-dataset-1m-records-20242026

##  Author

**Emmanuel Kouraogo**  
Data Science  Statistical Analysis  SAS Programming  
[GitHub](https://github.com/EKOURAOGO) | [LinkedIn](https://linkedin.com/in/ekouraogo)

##  License

MIT License  See LICENSE file for details

##  Acknowledgments

- Kaggle for public e-commerce dataset
- SAS Institute for software & documentation
- Enterprise analytics best practices

---

**Last Updated:** July 2026 | **Status:** Production-Ready | **SAS Version:** 9.4+

**Keywords:** SAS, E-Commerce, Analytics, Predictive Modeling, Customer Intelligence, Data Science, Business Analytics, PROC LOGISTIC, RFM Analysis, Churn Prediction
