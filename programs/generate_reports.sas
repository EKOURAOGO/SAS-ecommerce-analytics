/* ========================================================================= */
/* GENERATE REPORTS - AUTOMATED REPORTING PIPELINE                         */
/* ========================================================================= */

%put NOTE: Starting report generation...;

/* ========================================================================= */
/* REPORT 1: EXECUTIVE SUMMARY (RTF)                                       */
/* ========================================================================= */

ods rtf file="&output_root/reports/executive_summary.rtf" 
    style=journal bodytitle;

title1 "E-Commerce Analytics Platform";
title2 "Executive Summary Report";
title3 "%sysfunc(today(), ddmmyy10.)";

proc print data=work.segment_performance noobs;
    var customer_segment _freq_ _type_;
    title4 "Customer Segment Summary";
run;

proc means data=work.customer_metrics n mean std;
    title4 "Customer Metrics Summary";
run;

ods rtf close;

%put NOTE: Executive summary report created;

/* ========================================================================= */
/* REPORT 2: DATA QUALITY REPORT                                           */
/* ========================================================================= */

ods rtf file="&output_root/reports/data_quality_report.rtf" 
    style=journal bodytitle;

title1 "Data Quality Assessment";
title2 "%sysfunc(today(), ddmmyy10.)";

/* Missing values summary */
proc freq data=work.ecommerce_clean;
    title3 "Record Counts";
    tables transaction_type;
run;

/* Data completeness */
proc print data=work.customer_metrics(obs=5) noobs;
    title3 "Sample Records";
run;

ods rtf close;

%put NOTE: Data quality report created;

/* ========================================================================= */
/* REPORT 3: ANALYSIS RESULTS (ODS HTML)                                   */
/* ========================================================================= */

ods html file="&output_root/reports/analysis_results.html" style=journal;

title1 "E-Commerce Analytics - Detailed Results";

/* Customer segment analysis */
proc means data=work.customer_metrics n mean;
    class customer_segment;
    var customer_lifetime_value;
    title2 "Revenue by Segment";
run;

/* Model performance */
proc print data=work.fitstat noobs;
    title2 "Model Fit Statistics";
run;

ods html close;

%put NOTE: Analysis results report created;

/* ========================================================================= */
/* REPORT 4: EXECUTION LOG & SUMMARY                                       */
/* ========================================================================= */

data work.execution_log;
    analysis_date = today();
    total_records = 0;
    segments_analyzed = 3;
    models_built = 2;
    status = "Complete";
run;

proc print data=work.execution_log noobs;
    title "Pipeline Execution Summary";
run;

/* Export execution log */
proc export data=work.execution_log
    outfile="&output_root/logs/execution_summary.csv"
    dbms=csv replace;
run;

%put ========================================;
%put REPORT GENERATION COMPLETE;
%put ========================================;
%put Reports saved to: &output_root/reports/;
%put ========================================;
