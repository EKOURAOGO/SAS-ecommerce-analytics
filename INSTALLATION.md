# Installation Guide - SAS E-Commerce Analytics

## System Requirements

- **SAS Version:** 9.4+ or SAS Viya
- **OS:** Windows, Linux, macOS
- **Disk:** 5GB (2GB SAS, 2GB data, 1GB output)
- **RAM:** 8GB minimum (16GB recommended)

## Option 1: SAS Viya (Cloud-based)

1. Visit: https://www.sas.com/en_us/software/viya/viya-cloud-trial.html
2. Sign up for free 30-day trial
3. Access SAS Studio web interface
4. Ready to use - no installation

## Option 2: SAS University Edition (Local)

1. Download from: https://www.sas.com/en_us/software/university-edition.html
2. Install on Windows/Mac/Linux
3. Run via VirtualBox or Docker
4. Launch SAS Studio interface

## Option 3: SAS Studio Online (Web)

1. URL: https://www.sas.com/en_us/software/studio/studio-online.html
2. Create account & login
3. Ready to code

## Setup Steps

### Step 1: Get Project Files
```bash
git clone https://github.com/EKOURAOGO/sas-ecommerce-analytics
cd sas-ecommerce-analytics
```

### Step 2: Download Dataset
- Dataset: Global E-Commerce Dataset (+1M Records, 2024–2026)
- URL: https://www.kaggle.com/datasets/akrambelha/global-e-commerce-dataset-1m-records-20242026
- Place in: `data/ecommerce_raw.csv`

### Step 3: Update Configuration
Edit `programs/config.sas`:
```sas
%let project_root = /your/path/sas-ecommerce-analytics;
```

### Step 4: Create Directories
```bash
mkdir -p data/processed output/reports output/datasets output/logs
```

### Step 5: Run Analysis

In SAS Studio:
```sas
/* Load configuration */
%include '/path/to/programs/config.sas';

/* Run main analysis */
%include '/path/to/programs/main_analysis.sas';
```

Or execute pipeline:
```sas
%run_pipeline;
```

## Troubleshooting

### Issue: File Not Found
```sas
%put Checking: &raw_data;
%if %sysfunc(fileexist("&raw_data")) %then
    %put File exists
else
    %put File not found;
```

### Issue: Memory Error
```sas
options memsize=8000M compress=yes;
```

### Issue: Library Not Defined
```sas
libname output "&output_root";
proc datasets library=output;
quit;
```

## Validation

After setup, verify installation:
```sas
%init_project;
proc contents data=work.ecommerce_clean;
run;
```

Success indicators:
-  No errors in log
-  Data imported correctly
-  Directories created
-  Libraries defined

---

**Installation Guide Version:** 1.0 | **Updated:** July 2026
