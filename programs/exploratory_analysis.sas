/* ========================================================================= */
/* EXPLORATORY DATA ANALYSIS (EDA)                                         */
/* SAS E-COMMERCE ANALYTICS PROJECT                                        */
/* ========================================================================= */

options mprint symbolgen;

/* ========================================================================= */
/* STEP 1: UNIVARIATE ANALYSIS                                             */
/* ========================================================================= */

title1 "Univariate Analysis - Numeric Variables";

proc univariate data=work.ecommerce_clean;
    var product_price quantity order_value;
    histogram / normal kernel;
    probplot / normal;
run;

title1 "Univariate Analysis - Key Metrics";
proc univariate data=work.ecommerce_clean plot;
    var order_value days_since_purchase;
    inset n mean std min max / position=nw;
run;

/* ========================================================================= */
/* STEP 2: MULTIVARIATE ANALYSIS                                           */
/* ========================================================================= */

title1 "Correlation Matrix - All Numeric Variables";
proc corr data=work.ecommerce_clean pearson spearman;
    var product_price quantity order_value days_since_purchase;
    ods output pearsoncorr=work.corr_pearson;
run;

/* ========================================================================= */
/* STEP 3: CATEGORICAL ANALYSIS                                            */
/* ========================================================================= */

title1 "Frequency Analysis - Product Category";
proc freq data=work.ecommerce_clean;
    tables product_category / chisq;
    title2 "Chi-Square Test for Category Distribution";
run;

title1 "Cross-Tabulation - Category x Return Status";
proc freq data=work.ecommerce_clean;
    tables product_category * transaction_type / nocol norow expected;
run;

/* ========================================================================= */
/* STEP 4: SEGMENTATION ANALYSIS                                           */
/* ========================================================================= */

title1 "Customer Segmentation - Financial Metrics";
proc means data=work.customer_metrics n mean std min max;
    class customer_segment;
    var customer_lifetime_value purchase_frequency;
    output out=work.segment_stats;
run;

title1 "Segment Distribution";
proc freq data=work.customer_metrics;
    tables customer_segment;
run;

/* ========================================================================= */
/* STEP 5: TIME SERIES & TREND ANALYSIS                                    */
/* ========================================================================= */

data work.time_series;
    set work.ecommerce_clean;
    month = month(purchase_date);
    year = year(purchase_date);
    quarter = quarter(purchase_date);
    week = week(purchase_date);
run;

title1 "Monthly Revenue Trend";
proc means data=work.time_series nway;
    class year month;
    var order_value;
    output out=work.monthly_revenue sum=total_revenue;
run;

/* Plot monthly revenue */
proc sgplot data=work.monthly_revenue;
    series x=month y=total_revenue / group=year;
    title "Monthly Revenue Trend by Year";
    xaxis label="Month";
    yaxis label="Total Revenue ($)";
run;

title1 "Quarterly Performance";
proc means data=work.time_series nway;
    class year quarter;
    var order_value;
    output out=work.quarterly_revenue sum=total_revenue;
run;

/* ========================================================================= */
/* STEP 6: COMPARATIVE ANALYSIS                                            */
/* ========================================================================= */

title1 "Order Value by Transaction Type";
proc ttest data=work.ecommerce_clean;
    class transaction_type;
    var order_value;
run;

title1 "Average Order Value by Category";
proc means data=work.ecommerce_clean;
    class product_category;
    var order_value quantity;
    output out=work.category_summary;
run;

/* ========================================================================= */
/* STEP 7: DISTRIBUTION ANALYSIS                                           */
/* ========================================================================= */

title1 "Order Value Distribution Analysis";
proc univariate data=work.ecommerce_clean normal;
    var order_value;
    histogram order_value / normal kernel lognormal;
    inset n mean std skewness kurtosis / position=ne;
run;

/* ========================================================================= */
/* STEP 8: OUTLIER ANALYSIS                                                */
/* ========================================================================= */

%detect_outliers(dataset=work.ecommerce_clean, var=order_value, 
                 output=work.order_value_outliers);

title1 "Outlier Summary - Order Value";
proc freq data=work.order_value_outliers;
    tables is_outlier;
run;

/* ========================================================================= */
/* STEP 9: GEOGRAPHIC ANALYSIS                                             */
/* ========================================================================= */

%if %sysfunc(exist(work.ecommerce_clean)) %then %do;
    title1 "Regional Performance Analysis";
    proc means data=work.ecommerce_clean;
        class region;
        var order_value quantity;
        output out=work.regional_stats;
    run;
%end;

/* ========================================================================= */
/* STEP 10: CUSTOMER ANALYSIS                                              */
/* ========================================================================= */

title1 "Customer Purchase Patterns";
proc means data=work.customer_metrics;
    var customer_lifetime_value purchase_frequency days_since_last_purchase;
    output out=work.customer_summary;
run;

title1 "Customer Distribution by Value";
proc freq data=work.customer_metrics;
    tables customer_segment;
run;

/* ========================================================================= */
/* STEP 11: CREATE SUMMARY STATISTICS DATASET                              */
/* ========================================================================= */

data work.eda_summary;
    set work.segment_stats(in=seg)
        work.category_summary(in=cat)
        work.regional_stats(in=reg);
    
    if seg then analysis_type = 'Segment';
    if cat then analysis_type = 'Category';
    if reg then analysis_type = 'Region';
run;

proc export data=work.eda_summary
    outfile="&output_root/eda_summary.csv"
    dbms=csv replace;
run;

/* ========================================================================= */
/* STEP 12: VISUALIZATION SUMMARY                                          */
/* ========================================================================= */

title1 "Data Quality Metrics";
proc univariate data=work.ecommerce_clean;
    var order_value;
    ods select BasicMeasures ExtremeObs;
run;

%put ========================================;
%put EXPLORATORY ANALYSIS COMPLETE;
%put ========================================;
