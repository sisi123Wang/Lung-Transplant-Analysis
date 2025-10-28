# Lasso
library(glmnet)
library(dplyr)
dt_df <- as.data.frame(dt_unique)

#  binary AKI outcome
dt_df <- dt_df %>%
  mutate(
    aki_binary = case_when(
      acute_renal_failure_within == 1 ~ 0,  # None
      acute_renal_failure_within >= 2 ~ 1,  # Risk/Injury/Failure/Loss/ESRD → AKI
      TRUE ~ NA_real_
    ),
    aki_binary = factor(aki_binary, levels = c(0, 1))
  )
#mapping
mapping_table <- dt_df %>%
  filter(!is.na(acute_renal_failure_within)) %>%
  group_by(acute_renal_failure_within, aki_binary) %>%
  summarise(n = n(), .groups = "drop") %>%
  arrange(acute_renal_failure_within)

if (nrow(mapping_table) > 0) {
  cat("Binary Outcome (N patients)\n")
  for (i in 1:nrow(mapping_table)) {
    cat(sprintf("  %d → %s (%d patients)\n", 
                mapping_table$acute_renal_failure_within[i],
                as.character(mapping_table$aki_binary[i]),
                mapping_table$n[i]))
  }
}

# Select predictor variables
lasso_data <- dt_df %>%
  select(
    aki_binary,
    # Demographics & Baseline
    age_transplant, sex, bmi,
    
    # Primary Diagnosis
    primary_diagnosis,
    specific_primary_diagnosis___1, specific_primary_diagnosis___2,
    specific_primary_diagnosis___3, specific_primary_diagnosis___4,
    specific_primary_diagnosis___5, specific_primary_diagnosis___6,
    specific_primary_diagnosis___7, specific_primary_diagnosis___8,
    specific_primary_diagnosis___9, specific_primary_diagnosis___10,
    specific_primary_diagnosis___11, specific_primary_diagnosis___12,
    specific_primary_diagnosis___13,
    if_pulmonary_htn,
    
    # Transplant Characteristics
    las_at_transplant, cas_tx,
    
    # Pre-transplant Status
    patient_on_life_support, type_of_support, days_on_ecmo,
    condition_at_time_of_trans, functional_status_at_time,
    
    # Comorbidities
    diabetes, any_previous_malignancy, multi_drug_resistant_bacte,
    ever_smoked, lung_infection_requiring_i,
    
    # Prior Surgeries
    prior_cardiac_surgery, prior_lung_surgery_non_tra,
    prior_lung_transplant, tracheostomy, prior_pleurodesis,
    chronic_steroid_use_5_mg_2,
    
    # Cardiac Parameters
    pulmonary_artery_systolic, mean_pulmonary_capillary_w,
    cardiac_output_l_min, cardiac_index_l_m_m2,
    pulmonary_artery_diastolic, pulmonary_artery_mean_pres,
    ejection_fraction, rv_dysfunction, rvsp_or_spap,
    
    # Blood Type
    abo_group, rh,
    
    # Lab Values (Pre-op)
    most_recent_creatinine_mg, most_recent_total_bilirubi,
    most_recent_hemoglobin, most_recent_hematocrit,
    
    # Pulmonary Function
    fvc, fvc_predicted, fev1, fev1_predicted,
    fio2_estimate, paco2, pao2,
    perfusion_right_lung, perfusion_left_lung,
    ventilation_right_lung, ventilation_left_lung,
    
    # Donor Characteristics
    age, gender_donor, race_donor, diabetes_donor,
    cxr_abnormalities, pneumonia, secretions,
    ecd_extended_criteria, cause_of_death, donor_type,
    cmv_status_donor, ever_smoked_donor,
    estimated_pack_year_histor,
    best_pf_ratio_prior_to_ret, last_pf_ratio_prior_to_ret,
    evlp,
    
    # Surgical Details
    type_of_lung_transplant,
    warm_ischemic_time_left_lu, warm_ischemic_time_right_l,
    type_of_incision, skin_skin_time, skin_to_skin_time_2,
    chest_left_open,
    
    # ECLS/CPB
    use_of_ecls, if_yes_type_of_support,
    circuit_with_heparin_coati, if_cpb_or_modified_cpb_was,
    if_cpb_was_a_leukocyte_fil, if_cpb_pump_suckers_used,
    avalon_cannula, target_flow_rate, time_of_ecls,
    target_act, total_heparin_dose,
    nadir_temperature, nadir_hct,
    
    # Intraoperative Blood Products & Fluids
    cell_salvage, units_rbc_intraop, units_ffp_intraop,
    units_of_platelets, units_of_cryoprecipitate,
    total_amount_of_fluids_use,
    
    # Pressors
    type_of_pressor_used___0, type_of_pressor_used___1,
    type_of_pressor_used___2, type_of_pressor_used___3,
    type_of_pressor_used___4, type_of_pressor_used___5,
    type_of_pressor_used___6, type_of_pressor_used___7,
    use_of_inhaled_vasodilator,
    
    # Intraoperative ECLS
    intraoperative_ecls, type_of_ecls_used,
    was_there_a_conversion, type_of_ecls_conversion,
    
    # Postoperative ECLS
    postoperative_ecls,
    
    # Early Postoperative (first 24h - likely predictor, not outcome)
    total_fluids_in_first_24_h, type_of_post_op_fluids_in
    
  ) %>%
  filter(!is.na(aki_binary)) %>%
  mutate(
    # Convert character variables to numeric
    ejection_fraction = as.numeric(ejection_fraction),
    fev1 = as.numeric(fev1)
  )


cat("Dataset: dt_unique\n")
cat("Sample size:", nrow(lasso_data), "\n")
cat("AKI cases:", sum(as.numeric(lasso_data$aki_binary) - 1), "\n")
cat("Predictors:", ncol(lasso_data) - 1, "\n\n")

#y <- as.numeric(lasso_data$aki_binary) - 1
#X <- model.matrix(aki_binary ~ ., data = lasso_data)[, -1]
#cat("Complete cases before imputation:", sum(complete.cases(lasso_data)), "\n")

# DEBUG OF "X" Impute ALL missing values
lasso_data_clean <- lasso_data %>%
  mutate(across(where(is.numeric), ~{
    if(all(is.na(.))) {
      return(.)  # If all NA, leave as is
    } else {
      return(ifelse(is.na(.), median(., na.rm = TRUE), .))
    }
  })) %>%
  mutate(across(where(is.integer) & !where(is.factor), ~{
    if(all(is.na(.))) {
      return(.)
    } else {
      mode_val <- as.integer(names(sort(table(.), decreasing = TRUE))[1])
      return(ifelse(is.na(.), mode_val, .))
    }
  }))
cat("Remaining NAs after imputation:", sum(is.na(lasso_data_clean)), "\n")
cat("Complete cases after imputation:", sum(complete.cases(lasso_data_clean)), "\n")

if(sum(complete.cases(lasso_data_clean)) == 0) {
  na_cols <- colSums(is.na(lasso_data_clean))
  cat("Columns still with NAs:\n")
  print(na_cols[na_cols > 0])
}
y <- as.numeric(lasso_data_clean$aki_binary) - 1
X <- model.matrix(aki_binary ~ ., data = lasso_data_clean)[, -1]


cat("y length:", length(y), "\n")
cat("X dimensions:", dim(X), "\n")


set.seed(123)
suppressWarnings({
  cv_lasso <- cv.glmnet(X, y, family = "binomial", alpha = 1, nfolds = 5)
})


# Get coefficients
coef_lasso <- coef(cv_lasso, s = "lambda.1se")
selected <- rownames(coef_lasso)[which(coef_lasso[,1] != 0)]
selected <- setdiff(selected, "(Intercept)")
#nothing selected above

# If nothing selected, try lambda.min
if (length(selected) == 0) {
  cat("Lambda 1se too strict, using lambda.min\n")
  coef_lasso <- coef(cv_lasso, s = "lambda.min")
  selected <- rownames(coef_lasso)[which(coef_lasso[,1] != 0)]
  selected <- setdiff(selected, "(Intercept)")
}

# results is not good, only left with rbc as signifance variable when include all variables
coef_df <- data.frame(
  Variable = selected,
  Coefficient = as.numeric(coef_lasso[selected, 1])
) %>%
  arrange(desc(abs(Coefficient)))

print(coef_df, row.names = FALSE)

# ----Lasso with a smaller, clinically relevant set
# Select a smaller, clinically relevant set
lasso_data_focused <- dt_df %>%
  select(
    aki_binary,
    # Demographics
    age_transplant, sex, bmi,
    # Key clinical factors
    most_recent_creatinine_mg, diabetes, patient_on_life_support,
    # Intraoperative factors
    units_rbc_intraop, units_ffp_intraop, units_of_platelets,
    total_amount_of_fluids_use, use_of_ecls, intraoperative_ecls,
    time_of_ecls, nadir_temperature, nadir_hct,
    # Key cardiac parameters
    ejection_fraction, cardiac_index_l_m_m2,prior_lung_surgery_non_tra,primary_diagnosis,functional_status_at_time,
    # Transplant type
    type_of_lung_transplant
  ) %>%
  filter(!is.na(aki_binary)) %>%
  mutate(
    # Convert character to numeric
    ejection_fraction = as.numeric(ejection_fraction)
  )

# Check complete cases
cat("Complete cases before imputation:", sum(complete.cases(lasso_data_focused)), "\n")

# Impute missing values
lasso_data_focused <- lasso_data_focused %>%
  mutate(across(where(is.numeric), ~ifelse(is.na(.), median(., na.rm = TRUE), .))) %>%
  mutate(across(where(is.integer) & !aki_binary, ~{
    if(all(is.na(.))) return(.)
    mode_val <- as.integer(names(sort(table(.), decreasing = TRUE))[1])
    ifelse(is.na(.), mode_val, .)
  }))

# Verify no missing values remain
cat("Complete cases after imputation:", sum(complete.cases(lasso_data_focused)), "\n")
cat("Any NAs remaining:", any(is.na(lasso_data_focused)), "\n")

# Now create model matrix
y <- as.numeric(lasso_data_focused$aki_binary) - 1
X <- model.matrix(aki_binary ~ ., data = lasso_data_focused)[, -1]

cat("y length:", length(y), "\n")
cat("X dimensions:", dim(X), "\n")

# Run LASSO
set.seed(123)
suppressWarnings({
  cv_lasso <- cv.glmnet(X, y, family = "binomial", alpha = 1, nfolds = 5)
})


# units_rbc_intraop and units_of_platelets as signifance variable 
coef_lasso <- coef(cv_lasso, s = "lambda.min")
coef_df <- data.frame(
  Variable = rownames(coef_lasso)[-1],
  Coefficient = as.vector(coef_lasso)[-1]
) %>%
  filter(Coefficient != 0) %>%
  arrange(desc(abs(Coefficient)))

print(coef_df)

# ----- only selected variables from lasso ----
final_model_data <- lasso_data_focused %>%
  select(aki_binary, functional_status_at_time, units_rbc_intraop, 
         units_of_platelets, bmi, total_amount_of_fluids_use)

# Fit logistic regression
logistic_model <- glm(aki_binary ~ functional_status_at_time + units_rbc_intraop + 
                        units_of_platelets + bmi + total_amount_of_fluids_use,
                      data = final_model_data,
                      family = binomial(link = "logit"))
summary(logistic_model)



