# Lung-Transplant-Analysis-part A for AKI
This project is to test what degree does anemia, hypoxia, hypotension, and pre-existing kidney disease affect the incidence of AKI, need for dialysis at discharge, and mortality.

1. The baseline one-row-per-patient data with AKI + outcomes.
2. Table 1 (baseline by AKI)
3. Table 2 (outcomes by AKI stage) to understand distributions.
4. LASSO to screen among pre-transplant/intra-op predictors for each endpoint.
5. cause-specific Cox proportional hazards model test after transplanted impact on death.
6. Firth‐penalized Cox model to see if AKI change the instantaneous hazard of death after transplant.

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


| Variable                     | HR (exp(coef)) | 95% CI (Lower–Upper) | p-value     | Interpretation                                                                                                            |
| ---------------------------- | -------------- | -------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------- |
| **Age (per year)**           | **1.046**      | 1.016 – 1.076        | **0.002**   | Each additional year of age increases the hazard of death by ~4.6%. Older patients face higher post-transplant mortality. |
| **Sex**                      | **1.84**       | 0.95 – 3.22          | **0.032**   | The male has lower hazard; the female has ~84% higher instantaneous risk of death.              |
| **Anemia (Hb)**              | 0.97           | 0.85 – 1.10          | 0.62        | No significant association between pre-operative hemoglobin and mortality.                                                |
| **Hypoxia (PF ratio)**       | 1.00           | 0.998 – 1.003        | 0.80        | No meaningful effect at this scale. The variable may need rescaling (per 50 or 100 mmHg).                                 |
| **Single vs Double Lung Tx** | 0.97           | 0.65 – 1.44          | 0.87        | Mortality risk is similar for single and double transplants.                                                              |
| **Post-operative ECMO**      | **2.93**       | **1.64 – 5.24**      | **0.00027** | Strong effect: patients needing ECMO after transplant have almost 3× higher hazard of death.                              |
| **Diabetes**                 | **1.50**       | **1.11 – 2.01**      | **0.0077**  | Diabetic patients have ~50% higher hazard of death than non-diabetics.                                                    |



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


# Among lung-transplant patients still alive and not retransplanted, how does each variable affect the instantaneous hazard (risk per day) of death? The cause-specific Cox proportional hazards model for death after lung transplant. (consored from death_event == 1)
| Variable                          | HR (exp(coef)) | 95% CI        | p-value | Interpretation                                                                                                                                                          |
|-----------------------------------|----------------|---------------|---------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **AKI (aki_binary)**              | 2.18           | 0.77 – 6.18   | 0.14    | Patients with AKI had about **2× higher instantaneous risk of death** than those without AKI, but this result is **not statistically significant** (wide CI → uncertain). |
| **Age**                           | 0.98 per year  | 0.95 – 1.01   | 0.18    | Each year older slightly lowered the estimated hazard, but **not significant**.                                                                                         |
| **Sex (Female vs Male)**          | 1.59           | 0.57 – 4.39   | 0.37    | Females showed higher risk, but with wide uncertainty (not significant).                                                                                                |
| **BMI**                           | 1.00           | 0.93 – 1.08   | 0.95    | No clear relationship.                                                                                                                                                  |
| **RBC units intra-op**            | 0.99           | 0.83 – 1.18   | 0.92    | No clear relationship.                                                                                                                                                  |
| **Platelets units**               | 1.14           | 0.69 – 1.87   | 0.62    | No clear relationship.                                                                                                                                                  |
| **Fluids (per 1000 mL)**          | 0.84           | 0.57 – 1.25   | 0.40    | Slight trend toward lower hazard with more fluid administration, not significant.                                                                                       |
| **Type of ECLS used**             | **0.096**      | **0.019 – 0.48** | **0.00445*** | **Strongly significant**: Those with this ECLS type had about **90% lower hazard of death** than the reference group.                                                   |
| **Post-operative ECLS**           | **3.69**       | **1.33 – 10.28** | **0.01241*** | **Highly significant**: Needing post-op ECLS was associated with about **3.7× higher hazard of death**.                                                                |


# After adjusting for pre-op comorbidities (diabetes types, malignancy, pulmonary infection, prior surgeries, etc.), does AKI change the instantaneous hazard of death after transplant? (Firth‐penalized Cox model)

| Variable                                | HR (exp(coef)) | 95% CI (Lower – Upper) | p-value   | Interpretation                                                                   |
| --------------------------------------- | -------------- | ---------------------- | --------- | -------------------------------------------------------------------------------- |
| **AKI (present vs none)**               | **1.75**       | 0.74 – 3.96            | 0.20      | Directionally higher mortality risk with AKI, but not statistically significant. |
| **Age (per year)**                      | 0.99           | 0.96 – 1.02            | 0.55      | No significant effect of age in this model.                                      |
| **Sex (female vs male)**                | 1.27           | 0.53 – 3.29            | 0.60      | No significant difference by sex.                                                |
| **BMI (per unit)**                      | 1.04           | 0.96 – 1.12            | 0.33      | Weak, nonsignificant trend.                                                      |
| **Diabetes (Type II)**                  | 14.86          | 0.84 – 155.54          | 0.063     | Possibly higher risk, but extremely wide CI (few events).                        |
| **Diabetes (other types)**              | 1.44 – 1.18    | (approx. 0.50 – 3.69)  | 0.48–0.92 | No clear effect; unstable estimates due to small cell counts.                    |
| **Any Previous Malignancy**             | 0.65           | 0.01 – 5.18            | 0.75      | No deaths among malignancy patients; coefficient stabilized by Firth correction. |
| **Lung Infection requiring IV therapy** | 0.77           | 0.06 – 4.21            | 0.79      | No clear association.                                                            |
| **Multi-drug Resistant Infection**      | 0.42           | 0.03 – 4.42            | 0.49      | No clear association.                                                            |
| **Prior Lung Transplant**               | 0.91           | 0.18 – 3.56            | —         | No clear association (estimate imprecise).                                       |
| **Prior Cardiac Surgery**               | 1.79           | 0.18 – 8.59            | 0.55      | No significant association.                                                      |
| **Tracheostomy**                        | 0.55           | 0.04 – 3.41            | 0.56      | No clear association.                                                            |

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Lung-Transplant-Analysis-part B for Mortality

# For each predictor on its own, is there evidence it’s associated with the instantaneous hazard of death after lung transplant?

<img width="708" height="836" alt="Screenshot 2025-11-06 at 11 33 33 AM" src="https://github.com/user-attachments/assets/ab407f49-8926-4a8c-a0b1-221afe66810d" />



In univariable Cox analysis, several intra- and postoperative factors showed significant associations with mortality after lung transplantation. Patients requiring postoperative extracorporeal life support (ECLS) had nearly a three-fold higher hazard of death (HR ≈ 2.9, p = 0.005), indicating that postoperative cardiopulmonary failure strongly predicts poor survival. Greater intra-operative transfusion volumes, including fresh frozen plasma, red blood cells, cryoprecipitate, and platelets—were also linked to higher mortality risk (HRs ≈ 1.1–1.3, p < 0.05), suggesting that heavier transfusion requirements reflect greater surgical complexity and physiological stress. Other perioperative and preoperative factors, such as age, sex, BMI, pulmonary hypertension, prior surgeries, or baseline renal and hematologic indices, did not show significant unadjusted associations with death. 


# Among patients who have not yet died or been censored at a given time, how do these covariates change the instantaneous hazard (risk per unit time) of death after lung transplant? ( A cause-specific Cox model) with n = 459 patients, 32 deaths

| Variable                 | Coefficient (β) | Hazard Ratio (exp(β)) | 95% CI (Lower–Upper) |   p-value | Interpretation                               |
| ------------------------ | --------------: | --------------------: | -------------------: | --------: | -------------------------------------------- |
| **Age at transplant**    |          0.0082 |                 1.008 |        0.992 – 1.043 |     0.637 | No significant effect of age on mortality    |
| **Sex (Male vs Female)** |           0.202 |                 1.224 |        0.553 – 2.711 |     0.618 | No difference in mortality by sex            |
| **BMI**                  |          0.0009 |                 1.001 |        0.937 – 1.070 |     0.979 | No association; violates PH (p=0.027)        |
| **Postoperative ECLS**   |       **0.937** |              **2.55** |      **1.09 – 5.97** | **0.031** | **Significant 2.5× higher mortality hazard** |
| **Units FFP (intra-op)** |           0.142 |                  1.15 |        0.887 – 1.495 |     0.288 | Weak, non-significant increase in risk       |
| **Units RBC (intra-op)** |          −0.028 |                  0.97 |        0.820 – 1.153 |     0.750 | No association with mortality                |


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Lung-Transplant-Analysis-part C for dialysis. It is worth notice that the event of dialysis is only 10. 

| Variable                   | OR   | 95% CI         | P_value |
|---------------------------|------|----------------|---------|
| peak_creatinine_within_48 | 3.92 | (0, 56.23)     | 0.298   |
| units_rbc_intraop         | 1.24 | (0.52, 1.74)   | 0.206   |









