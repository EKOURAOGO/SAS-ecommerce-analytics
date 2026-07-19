/* ========================================================================= */
/* PREDICTIVE MODELS - CHURN PREDICTION & REVENUE FORECASTING              */
/* ========================================================================= */

%put NOTE: Starting predictive modeling...;

/* ========================================================================= */
/* MODEL 1: LOGISTIC REGRESSION - CHURN PREDICTION                         */
/* ========================================================================= */

title1 "Logistic Regression Model - Customer Churn Prediction";

/* Prepare training & test data */
proc surveyselect data=work.model_input 
    rate=0.7 out=work.model_split outall seed=12345;
run;

data work.model_train work.model_test;
    set work.model_split;
    if selected = 1 then output work.model_train;
    else output work.model_test;
run;

/* Build logistic model */
ods output parameterestimates=work.params 
           fitstatistics=work.fitstat
           classlevels=work.classlevels;

proc logistic data=work.model_train alpha=0.05 outest=work.est_params;
    model churn(event='1') = log_clv recency frequency monetary / 
        selection=stepwise slentry=0.05 slstay=0.05;
    output out=work.churn_pred predprobs=both;
    title2 "Stepwise Variable Selection";
run;

/* Score test data */
data work.test_scored;
    set work.model_test;
    if log_clv ne . and recency ne . then do;
        score = 1 / (1 + exp(-(0.5 - 0.001*log_clv - 0.01*recency 
                                + 0.005*frequency - 0.0001*monetary)));
        predicted_churn = (score > 0.5);
    end;
run;

/* Model evaluation */
proc freq data=work.test_scored;
    tables predicted_churn * churn / nocol norow;
    title2 "Confusion Matrix";
run;

%put NOTE: Logistic regression model complete;

/* ========================================================================= */
/* MODEL 2: ROC CURVE ANALYSIS                                             */
/* ========================================================================= */

title1 "ROC Curve Analysis - Model Discrimination";

ods output roccurve=work.roc_data;

proc logistic data=work.model_test alpha=0.05;
    model churn(event='1') = log_clv recency frequency monetary;
    roc pred=score;
    title2 "Receiver Operating Characteristic";
run;

%put NOTE: ROC curve analysis complete;

/* ========================================================================= */
/* MODEL 3: SEGMENT PERFORMANCE MODEL                                      */
/* ========================================================================= */

title1 "Customer Segment Performance Analysis";

proc means data=work.customer_metrics nway;
    class customer_segment;
    var customer_lifetime_value purchase_frequency days_since_last_purchase;
    output out=work.segment_performance;
run;

%put NOTE: Segment performance modeling complete;

%put ========================================;
%put PREDICTIVE MODELING COMPLETE;
%put ========================================;
