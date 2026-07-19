/* ========================================================================= */
/* QUALITY CHECKS & DATA VALIDATION                                        */
/* ========================================================================= */

%put NOTE: Running data quality checks...;

/* Check for duplicates */
proc sql;
    title "Duplicate Records Check";
    select count(*) as total_records,
           count(distinct order_id) as unique_orders,
           calculated total_records - calculated unique_orders as duplicates
    from work.ecommerce_clean;
quit;

/* Missing value summary */
%missing_summary(dataset=work.ecommerce_clean);

%put NOTE: Quality checks complete;
