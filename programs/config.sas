/* ========================================================================= */
/* CONFIGURATION & GLOBAL SETTINGS                                         */
/* SAS E-COMMERCE ANALYTICS PROJECT                                        */
/* ========================================================================= */

/* ========================================================================= */
/* OPTIONS & SYSTEM SETTINGS                                               */
/* ========================================================================= */

options 
    /* Performance */
    compress=yes 
    nocmdmac 
    nonotes 
    nostimer
    validvarname=v7
    
    /* Output */
    formchar="|----|+|---+=|-/\<>*"
    linesize=200
    pagesize=60
    
    /* Graphics */
    gstyle=journal
    encoding=utf8;

ods graphics on / width=1000px height=700px antialiasmax=5000;
ods html path="&output_root/html" body="index.html" style=journal;

/* ========================================================================= */
/* GLOBAL MACRO VARIABLES                                                  */
/* ========================================================================= */

/* Paths */
%let project_root = /sas-ecommerce-analytics;
%let data_root = &project_root/data;
%let programs_root = &project_root/programs;
%let output_root = &project_root/output;
%let config_root = &project_root/config;

/* Data sources */
%let raw_data = &data_root/ecommerce_raw.csv;
%let processed_data = work.ecommerce_clean;
%let customer_data = work.customer_metrics;

/* Analysis parameters */
%let train_test_split = 0.70;
%let random_seed = 12345;
%let alpha_level = 0.05;
%let model_selection = stepwise;

/* Churn modeling */
%let churn_threshold_days = 180;
%let churn_target = churn;
%let churn_predictors = log_clv recency frequency monetary;

/* Output specifications */
%let report_format = rtf;
%let output_dataset_format = csv;
%let graphics_dpi = 300;

/* Process flags */
%let run_quality_checks = 1;
%let run_eda = 1;
%let run_models = 1;
%let run_export = 1;
%let run_reports = 1;

/* ========================================================================= */
/* LIBRARY DEFINITIONS                                                      */
/* ========================================================================= */

libname rawdata "&data_root";
libname procdata "&data_root/processed";
libname output "&output_root";
libname config "&config_root";

/* ========================================================================= */
/* FORMATTING DEFINITIONS                                                   */
/* ========================================================================= */

/* Currency format */
proc format;
    picture currency (default=11)
        low-high = '000,000.00' (prefix='$');
    
    /* Percentage format */
    picture percentage (default=8)
        0-1 = '9.99%';
    
    /* Custom formats */
    value churn
        0 = 'Retained'
        1 = 'Churned';
    
    value segment
        'Low' = 'Low Value'
        'Medium' = 'Medium Value'
        'High' = 'High Value';
    
    value transaction
        'Sale' = 'Purchase'
        'Return' = 'Return';
run;

/* ========================================================================= */
/* MACRO FOR PROJECT INITIALIZATION                                        */
/* ========================================================================= */

%macro init_project;
    %put ========================================;
    %put SAS E-COMMERCE ANALYTICS PROJECT;
    %put Initialization: %sysfunc(today(), ddmmyy10.);
    %put ========================================;
    
    %put Project Root: &project_root;
    %put Data Root: &data_root;
    %put Output Root: &output_root;
    
    /* Create output directories if they don't exist */
    %put Checking output directories...;
    
    /* Verify data exists */
    %if %sysfunc(fileexist("&raw_data")) %then %do;
        %put Raw data file found: &raw_data;
    %end;
    %else %do;
        %put WARNING: Raw data file not found: &raw_data;
    %end;
    
    %put ========================================;
    %put Initialization Complete;
    %put ========================================;
%mend init_project;

/* ========================================================================= */
/* PROJECT EXECUTION MACRO                                                  */
/* ========================================================================= */

%macro run_pipeline;
    %put ========================================;
    %put EXECUTING ANALYSIS PIPELINE;
    %put ========================================;
    
    /* Initialize */
    %init_project;
    
    /* Step 1: Quality checks */
    %if &run_quality_checks = 1 %then %do;
        %put Running quality checks...;
        %include "&programs_root/quality_checks.sas";
    %end;
    
    /* Step 2: EDA */
    %if &run_eda = 1 %then %do;
        %put Running exploratory analysis...;
        %include "&programs_root/exploratory_analysis.sas";
    %end;
    
    /* Step 3: Modeling */
    %if &run_models = 1 %then %do;
        %put Running predictive models...;
        %include "&programs_root/predictive_models.sas";
    %end;
    
    /* Step 4: Export */
    %if &run_export = 1 %then %do;
        %put Exporting results...;
        %include "&programs_root/export_results.sas";
    %end;
    
    /* Step 5: Reports */
    %if &run_reports = 1 %then %do;
        %put Generating reports...;
        %include "&programs_root/generate_reports.sas";
    %end;
    
    %put ========================================;
    %put PIPELINE EXECUTION COMPLETE;
    %put ========================================;
%mend run_pipeline;

/* Initialization complete */
%put Configuration loaded successfully;
