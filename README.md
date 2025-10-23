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
Outcome: AKI (yes/no)
Predictors: functional status, intraop RBC units, platelet units, BMI, total fluids.

RBC units (estimate 0.170, p=0.022)
OR ≈ 1.19 per unit (exp(0.1699)):  each additional RBC unit ~19% higher odds of AKI.

Total fluids (mL) (estimate −0.000281, p=0.030)
Per 1,000 mL: OR ≈ exp(−0.000281×1000) ≈ 0.76: more fluids associated with lower odds of AKI.

Model fit: Residual deviance 297 vs null 329 (AIC 309). 

After controlling for all covariates, RBC transfusions significantly increase AKI risk (OR 1.19 per unit, p=0.022), while higher intraoperative fluid volumes paradoxically associate with lower AKI risk (OR 0.76 per liter, p=0.030), with functional status and BMI showing borderline significance. Multicollinearity is not a concern (all VIF < 3), indicating independent predictor effects. The model shows adequate overall fit (residual deviance 297 vs null 329, AIC 309, p<0.001). 






