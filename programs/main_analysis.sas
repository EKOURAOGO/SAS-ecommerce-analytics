/* ========================================================================= */
/* E-COMMERCE ANALYTICS: SAS PROJECT                                       */
/* Data Import & Exploratory Analysis Pipeline                             */
/* ========================================================================= */

%put NOTE: Loading configuration...;
%include "&programs_root/config.sas";

options validvarname=v7 mprint symbolgen;
ods graphics on / width=10in height=6in;

/* ========================================================================= */
/* STEP 1: IMPORT DATA FROM KAGGLE E-COMMERCE DATASET                      */
/* ========================================================================= */

%put NOTE: Importing data from &raw_data;

proc import datafile="&raw_data"
    out=work.ecommerce_raw
    dbms=csv
    replace;
    getnames=yes;
    guessingrows=5000;
run;

%if &syserr ne 0 %then %do;
    %put ERROR: Data import failed with SYSERR=&syserr;
    %abort;
%end;

/* ========================================================================= */
/* STEP 2: DATA EXPLORATION & QUALITY CHECKS                               */
/* ========================================================================= */

title "Dataset Overview - Global E-Commerce Analytics";

proc contents data=work.ecommerce_raw short;
run;

proc print data=work.ecommerce_raw(obs=10);
run;

proc means data=work.ecommerce_raw n nmiss min max mean std;
run;

/* ========================================================================= */
/* STEP 3: DATA CLEANING & TRANSFORMATION                                  */
/* ========================================================================= */

data work.ecommerce_clean;
    set work.ecommerce_raw;
    
    /* Remove duplicates */
    if order_id = lag(order_id) then delete;
    
    /* Handle missing values */
    if missing(customer_age) then customer_age = .;
    if missing(product_price) then product_price = .;
    if missing(quantity) then quantity = 1;
    
    /* Create derived variables */
    order_value = product_price * quantity;
    
    /* Segment customers by purchase value */
    if order_value < 50 then customer_segment = 'Low';
    else if order_value < 200 then customer_segment = 'Medium';
    else customer_segment = 'High';
    
    /* Calculate days since purchase */
    purchase_date = input(order_date, ddmmyy10.);
    days_since_purchase = today() - purchase_date;
    format purchase_date ddmmyy10.;
    
    /* Customer lifetime value indicator */
    if return_status = 'Returned' then transaction_type = 'Return';
    else transaction_type = 'Sale';
    
run;

proc sort data=work.ecommerce_clean out=work.ecommerce_sorted;
    by customer_id order_id;
run;

/* ========================================================================= */
/* STEP 4: AGGREGATE TO CUSTOMER LEVEL                                     */
/* ========================================================================= */

proc summary data=work.ecommerce_clean nway;
    class customer_id;
    var order_value quantity days_since_purchase;
    output out=work.customer_metrics
        sum=total_spent total_quantity
        mean=avg_order_value avg_days_since_purchase
        n=purchase_count;
run;

data work.customer_metrics;
    set work.customer_metrics;
    customer_lifetime_value = total_spent;
    purchase_frequency = purchase_count;
    days_since_last_purchase = avg_days_since_purchase;
    drop _type_ _freq_;
run;

/* ========================================================================= */
/* STEP 5: STATISTICAL ANALYSIS - DESCRIPTIVE                              */
/* ========================================================================= */

title1 "Statistical Summary by Product Category";
proc means data=work.ecommerce_clean n mean std min max;
    class product_category;
    var product_price quantity order_value;
run;

title1 "Return Rate Analysis";
proc freq data=work.ecommerce_clean;
    tables transaction_type / nocum nopercent;
run;

title1 "Customer Segment Distribution";
proc freq data=work.ecommerce_clean;
    tables customer_segment;
run;

/* ========================================================================= */
/* STEP 6: PREDICTIVE MODEL - CUSTOMER CHURN / RETENTION                   */
/* ========================================================================= */

/* Prepare data for modeling */
data work.model_input;
    set work.customer_metrics;
    
    /* Target: Churn indicator (no purchase in last 180 days) */
    if days_since_last_purchase > 180 then churn = 1;
    else churn = 0;
    
    /* Features */
    log_clv = log(customer_lifetime_value + 1);
    recency = days_since_last_purchase;
    frequency = purchase_frequency;
    monetary = customer_lifetime_value / (purchase_frequency + 1);
    
    /* Remove missing */
    if missing(churn) or missing(log_clv) then delete;
    
run;

/* Split data: 70% train, 30% test */
proc surveyselect data=work.model_input rate=0.7
    out=work.model_split outall seed=12345;
run;

data work.model_train work.model_test;
    set work.model_split;
    if selected = 1 then output work.model_train;
    else output work.model_test;
run;

/* Logistic Regression for Churn Prediction */
ods output parameterestimates=work.params fitstatistics=work.fitstat;

proc logistic data=work.model_train alpha=0.05;
    model churn(event='1') = log_clv recency frequency monetary / 
        selection=stepwise slentry=0.05 slstay=0.05;
    output out=work.churn_pred predprobs=both;
run;

/* Score test data */
proc logistic data=work.model_train alpha=0.05 outest=work.est_params;
    model churn(event='1') = log_clv recency frequency monetary;
run;

data work.test_scored;
    set work.model_test;
    score = 1 / (1 + exp(-(coeff_intercept + coeff_log_clv*log_clv 
                          + coeff_recency*recency + coeff_frequency*frequency 
                          + coeff_monetary*monetary)));
run;

/* ========================================================================= */
/* STEP 7: MODEL EVALUATION                                                */
/* ========================================================================= */

title1 "Model Performance - Classification Statistics";
proc freq data=work.test_scored;
    tables predicted_churn * churn / norow nocol;
run;

/* ROC Curve */
ods output roccurve=work.roc_data;
proc logistic data=work.model_test alpha=0.05 outroc=work.roc_output;
    model churn(event='1') = log_clv recency frequency monetary;
    roc pred=predicted_probability;
run;

/* ========================================================================= */
/* STEP 8: GENERATE INSIGHTS & REPORTS                                     */
/* ========================================================================= */

title1 "Top 20 Customers by Lifetime Value";
proc sort data=work.customer_metrics out=work.top_customers 
         descending;
    by customer_lifetime_value;
run;

proc print data=work.top_customers(obs=20) noobs;
    var customer_id customer_lifetime_value purchase_frequency;
run;

title1 "Revenue by Product Category";
proc summary data=work.ecommerce_clean;
    class product_category;
    var order_value;
    output out=work.category_revenue sum=total_revenue;
run;

proc sort data=work.category_revenue(where=(_type_=1));
    by descending total_revenue;
run;

proc print data=work.category_revenue noobs;
    var product_category total_revenue;
run;

/* ========================================================================= */
/* STEP 9: ODS OUTPUT - GENERATE REPORTS                                   */
/* ========================================================================= */

ods rtf file="&output_root/reports/ecommerce_analysis_report.rtf" style=journal;

title1 "E-Commerce Analytics Report";
title2 "Comprehensive Customer & Sales Analysis";

proc report data=work.ecommerce_clean nowindows;
    column product_category order_value quantity;
    define product_category / group;
    define order_value / sum format=dollar10.2;
    define quantity / sum;
run;

ods rtf close;

/* ========================================================================= */
/* STEP 10: DATA EXPORT FOR EXTERNAL USE                                   */
/* ========================================================================= */

proc export data=work.customer_metrics
    outfile="&output_root/datasets/customer_metrics.csv"
    dbms=csv replace;
run;

proc export data=work.test_scored
    outfile="&output_root/datasets/churn_predictions.csv"
    dbms=csv replace;
run;

/* ========================================================================= */
/* EXECUTION LOG & SUMMARY                                                  */
/* ========================================================================= */

proc sql noprint;
    select nobs into :n_clean from sashelp.vtable 
        where libname='WORK' and memname='ECOMMERCE_CLEAN';
    select nobs into :n_customers from sashelp.vtable 
        where libname='WORK' and memname='CUSTOMER_METRICS';
    select nobs into :n_train from sashelp.vtable 
        where libname='WORK' and memname='MODEL_TRAIN';
    select nobs into :n_test from sashelp.vtable 
        where libname='WORK' and memname='MODEL_TEST';
quit;

%put ========================================;
%put SAS E-COMMERCE ANALYSIS PIPELINE COMPLETE;
%put ========================================;
%put Analysis Date: %sysfunc(today(), ddmmyy10.);
%put Observations Processed: &n_clean;
%put Customers Analyzed: &n_customers;
%put Model Training Observations: &n_train;
%put Model Testing Observations: &n_test;
%put ========================================;
%put Output Location: &output_root;
%put ========================================;

quit;
