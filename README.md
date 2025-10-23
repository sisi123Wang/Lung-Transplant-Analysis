# Lung-Transplant-Analysis
This project is to test what degree does anemia, hypoxia, hypotension, and pre-existing kidney disease affect the incidence of AKI, need for dialysis at discharge, and mortality.

1. The baseline one-row-per-patient data with AKI + outcomes.
2. Table 1 (baseline by AKI)
3. Table 2 (outcomes by AKI stage) to understand distributions.
4. LASSO to screen among pre-transplant/intra-op predictors for each endpoint.

Lasso: 
I firstly convert the AKI as a binary AKI outcome, with 1= No AKI, 2-6=Risk/Injury/Failure/Loss/ESRD as AKI

The potential problem with AKI is the sample size of having AKI is only 48/460. 

Here is the Lasso model result (I used dt_unique baseline data with one row per patient, not include follow-up information ): 
| Variable | Coefficient |
|----------|-------------|
| functional_status_at_time | 1.820837e-01 |
| units_rbc_intraop | 1.200803e-01 |
| units_of_platelets | 7.706624e-02 |
| bmi | 1.292697e-02 |
| total_amount_of_fluids_use | -7.493584e-05 |

Primary models: Prespecified clinical covariates plus any LASSO-selected predictors.

