# Lung-Transplant-Analysis-part A for AKI
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


# Cox Regression
This model was fitted to estimate hazard ratios (HR) for time-to-death, censoring at retransplantation or last follow-up. The model included age, sex, preoperative hemoglobin (anemia_hb), hypoxia severity (hypoxia_pf), transplant type (single vs double), postoperative ECMO requirement, and diabetes status as covariates.
<img width="649" height="694" alt="Screenshot 2025-10-23 at 4 16 57 PM" src="https://github.com/user-attachments/assets/eae9cac4-829e-49d4-81f2-5b96c964b2ef" />


# Poisson Regression Model
By modeling the rate of mortality events with person-time as an offset term, this approach estimates rate ratios (RR) under the assumption of constant hazard rates. Heteroskedasticity-consistent standard errors (HC0) were employed to provide robust inference against model misspecification and overdispersion.
Both models utilized complete case analysis, with the Poisson model analyzing 522 patients and the Cox model analyzing 521 patients (1 observation deleted due to missingness).

<img width="595" height="346" alt="Screenshot 2025-10-23 at 4 19 51 PM" src="https://github.com/user-attachments/assets/e2e94d89-bcb7-42e2-8e41-f6ab0e8cff0d" />

# Model Performance
The Cox model demonstrated excellent discrimination with a concordance index of 0.74 (SE = 0.031). Both models identified age as a significant mortality risk factor. The Cox model estimated a 4.6% increase in hazard per year (HR = 1.046, 95% CI: 1.016-1.076, p = 0.002), while the Poisson model showed similar magnitude (RR = 1.051, p = 0.004).
Male sex was associated with increased mortality risk in both models. The Cox analysis yielded HR = 1.84 (95% CI: 1.055-3.219, p = 0.032), closely matched by the Poisson RR = 1.81 (p = 0.043).
The requirement for postoperative extracorporeal membrane oxygenation emerged as the strongest predictor of mortality. Cox regression estimated HR = 2.93 (95% CI: 1.644-5.238, p < 0.001), with the Poisson model yielding RR = 3.15 (p < 0.001).
Diabetes was significantly associated with increased mortality risk. The Cox model estimated HR = 1.50 (95% CI: 1.112-2.012, p = 0.008). The Poisson model revealed heterogeneity across diabetes categories, with rate ratios ranging from 2.41 to 4.25 (p = 0.007-0.028), though one category showed an anomalous protective effect (RR = 1.16×10⁻⁶).
Non-significant Predictors: Neither preoperative anemia (hemoglobin level), hypoxia severity (PF ratio), nor transplant type (single vs double lung) reached statistical significance in either model, suggesting these factors may not be independent predictors of mortality after adjustment for other covariates.





