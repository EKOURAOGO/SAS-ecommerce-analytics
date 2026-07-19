/* ========================================================================= */
/* EXPORT RESULTS - DATA EXPORT & ARCHIVE                                  */
/* ========================================================================= */

%put NOTE: Starting results export...;

/* ========================================================================= */
/* EXPORT 1: CUSTOMER METRICS                                              */
/* ========================================================================= */

title "Exporting Customer Metrics";

proc export data=work.customer_metrics
    outfile="&output_root/datasets/customer_metrics.csv"
    dbms=csv replace;
    putnames=yes;
run;

%put NOTE: Customer metrics exported;

/* ========================================================================= */
/* EXPORT 2: CHURN PREDICTIONS                                             */
/* ========================================================================= */

title "Exporting Churn Predictions";

proc export data=work.test_scored
    outfile="&output_root/datasets/churn_predictions.csv"
    dbms=csv replace;
    putnames=yes;
run;

%put NOTE: Churn predictions exported;

/* ========================================================================= */
/* EXPORT 3: SEGMENT ANALYSIS                                              */
/* ========================================================================= */

title "Exporting Segment Analysis";

proc export data=work.segment_performance
    outfile="&output_root/datasets/segment_performance.csv"
    dbms=csv replace;
    putnames=yes;
run;

%put NOTE: Segment analysis exported;

/* ========================================================================= */
/* EXPORT 4: FEATURE IMPORTANCE (from models)                              */
/* ========================================================================= */

title "Exporting Parameter Estimates";

proc export data=work.est_params
    outfile="&output_root/datasets/model_parameters.csv"
    dbms=csv replace;
    putnames=yes;
run;

%put NOTE: Model parameters exported;

/* ========================================================================= */
/* EXPORT 5: ROC CURVE DATA                                                */
/* ========================================================================= */

title "Exporting ROC Curve Data";

proc export data=work.roc_data
    outfile="&output_root/datasets/roc_curve.csv"
    dbms=csv replace;
    putnames=yes;
run;

%put NOTE: ROC curve data exported;

/* ========================================================================= */
/* ARCHIVE: SAS DATASETS                                                   */
/* ========================================================================= */

/* Save key datasets for future reference */
proc copy in=work out=output;
    select customer_metrics test_scored segment_performance 
           est_params roc_data;
run;

%put NOTE: Datasets archived;

%put ========================================;
%put EXPORT COMPLETE;
%put ========================================;
