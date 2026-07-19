/* ========================================================================= */
/* SAS MACROS FOR REUSABLE ANALYTICS FUNCTIONS                             */
/* ========================================================================= */

/* ========================================================================= */
/* MACRO 1: DATA QUALITY ASSESSMENT                                        */
/* ========================================================================= */

%macro assess_data_quality(dataset=, output=quality_report);
    %put NOTE: Starting data quality assessment for &dataset;
    
    proc sql noprint;
        select nobs into :num_obs from sashelp.vtable 
        where libname='WORK' and memname="%upcase(&dataset)";
    quit;
    
    data &output;
        set &dataset end=eof;
        
        if _n_ = 1 then do;
            call execute('proc contents data='||"&dataset"||
                         ' out=content_out noprint; run;');
        end;
        
        array _numeric _numeric_;
        array _char _char_;
        
        do over _numeric;
            if missing(_numeric) then missing_numeric = missing_numeric + 1;
        end;
        
        do over _char;
            if missing(_char) then missing_char = missing_char + 1;
        end;
        
        if eof then do;
            output;
        end;
    run;
    
    %put NOTE: Data quality report created in &output;
%mend assess_data_quality;

/* ========================================================================= */
/* MACRO 2: AUTOMATED FREQUENCY ANALYSIS                                   */
/* ========================================================================= */

%macro freq_analysis(dataset=, var=, max_levels=10);
    %local var_count;
    %local i;
    %local current_var;
    
    %let var_count = %sysfunc(countw(&var));
    
    %do i=1 %to &var_count;
        %let current_var = %scan(&var, &i);
        
        title "Frequency Analysis: &current_var";
        
        proc freq data=&dataset order=freq;
            tables &current_var / nocum;
            where &current_var is not missing;
        run;
        
    %end;
%mend freq_analysis;

/* ========================================================================= */
/* MACRO 3: AUTOMATED CORRELATION ANALYSIS                                 */
/* ========================================================================= */

%macro correlation_analysis(dataset=, vars=, output=corr_matrix);
    %put NOTE: Computing correlation matrix for &vars;
    
    proc corr data=&dataset pearson spearman out=&output;
        var &vars;
    run;
    
    %put NOTE: Correlation analysis complete;
%mend correlation_analysis;

/* ========================================================================= */
/* MACRO 4: MISSING VALUE SUMMARY                                          */
/* ========================================================================= */

%macro missing_summary(dataset=);
    proc sql;
        title "Missing Value Summary";
        select name, 
               count(*) as total_obs,
               sum(case when missing(.) then 1 else 0 end) as missing_count,
               (calculated missing_count) / (calculated total_obs) as pct_missing format=percent8.2
        from &dataset
        group by name
        having calculated missing_count > 0
        order by calculated pct_missing desc;
    quit;
%mend missing_summary;

/* ========================================================================= */
/* MACRO 5: OUTLIER DETECTION USING IQR METHOD                             */
/* ========================================================================= */

%macro detect_outliers(dataset=, var=, output=outliers_detected);
    %put NOTE: Detecting outliers in &var using IQR method;
    
    proc univariate data=&dataset;
        var &var;
        output out=percentiles pctlpts=25 75 pctlpre=p;
    run;
    
    data &output;
        set &dataset;
        if _n_ = 1 then set percentiles;
        
        iqr = p75 - p25;
        lower_bound = p25 - (1.5 * iqr);
        upper_bound = p75 + (1.5 * iqr);
        
        if &var < lower_bound or &var > upper_bound then is_outlier = 1;
        else is_outlier = 0;
        
        keep &var lower_bound upper_bound is_outlier;
    run;
%mend detect_outliers;

/* ========================================================================= */
/* MACRO 6: SEGMENTATION ANALYSIS                                          */
/* ========================================================================= */

%macro segment_analysis(dataset=, segment_var=, metric_var=);
    %put NOTE: Analyzing segments by &segment_var on &metric_var;
    
    proc means data=&dataset n mean std min max;
        class &segment_var;
        var &metric_var;
        title "Segment Analysis: &metric_var by &segment_var";
    run;
    
    proc freq data=&dataset;
        tables &segment_var;
        title "Segment Distribution";
    run;
%mend segment_analysis;

/* ========================================================================= */
/* MACRO 7: LOGISTIC REGRESSION WITH DIAGNOSTICS                           */
/* ========================================================================= */

%macro logistic_model(dataset=, target=, predictors=, output_dataset=predictions);
    %put NOTE: Building logistic regression model;
    
    proc logistic data=&dataset alpha=0.05 outest=params outlag=lag;
        model &target(event='1') = &predictors / selection=stepwise slentry=0.05 slstay=0.05;
        output out=&output_dataset predicted=pred_prob prob=prob;
        title "Logistic Regression: &target ~ &predictors";
    run;
    
    %put NOTE: Model estimation complete;
%mend logistic_model;

/* ========================================================================= */
/* MACRO 8: ROC CURVE GENERATION                                           */
/* ========================================================================= */

%macro roc_analysis(dataset=, target=, predictor=, output_roc=roc_curve);
    %put NOTE: Generating ROC curve;
    
    ods output roccurve=&output_roc;
    
    proc logistic data=&dataset outroc=&output_roc;
        model &target(event='1') = &predictor;
        roc pred=&predictor;
        title "ROC Curve Analysis";
    run;
%mend roc_analysis;

%put NOTE: All macros loaded successfully;
