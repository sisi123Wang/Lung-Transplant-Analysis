# UNIVARIATE ANALYSIS
library(dplyr)
library(forcats)
library(gtsummary)

# Reuse the exact Table 1 variable set
t1_df <- table1_data %>%
  select(
    aki_binary,
    age_transplant, sex, bmi,
    primary_diagnosis,
    starts_with("specific_primary_diagnosis___"),
    if_pulmonary_htn, las_at_transplant, cas_tx,
    patient_on_life_support, type_of_support, days_on_ecmo,
    condition_at_time_of_trans, functional_status_at_time,
    diabetes, any_previous_malignancy, multi_drug_resistant_bacte,
    ever_smoked, lung_infection_requiring_i,
    prior_cardiac_surgery, prior_lung_surgery_non_tra,
    prior_lung_transplant, tracheostomy, prior_pleurodesis,
    chronic_steroid_use_5_mg_2,
    pulmonary_artery_systolic, mean_pulmonary_capillary_w,
    cardiac_output_l_min, cardiac_index_l_m_m2,
    pulmonary_artery_diastolic, pulmonary_artery_mean_pres,
    ejection_fraction, rv_dysfunction, rvsp_or_spap,
    abo_group, rh,
    most_recent_creatinine_mg, most_recent_total_bilirubi,
    most_recent_hemoglobin, most_recent_hematocrit,
    fvc, fvc_predicted, fev1, fev1_predicted,
    fio2_estimate, paco2, pao2,
    perfusion_right_lung, perfusion_left_lung,
    ventilation_right_lung, ventilation_left_lung,
    age, gender_donor, race_donor, diabetes_donor,
    cxr_abnormalities, pneumonia, secretions,
    ecd_extended_criteria, cause_of_death, donor_type,
    cmv_status_donor, ever_smoked_donor,
    estimated_pack_year_histor,
    best_pf_ratio_prior_to_ret, last_pf_ratio_prior_to_ret,
    evlp,
    type_of_lung_transplant,
    warm_ischemic_time_left_lu, warm_ischemic_time_right_l,
    type_of_incision, skin_skin_time, skin_to_skin_time_2,
    chest_left_open,
    use_of_ecls, if_yes_type_of_support,
    circuit_with_heparin_coati, if_cpb_or_modified_cpb_was,
    if_cpb_was_a_leukocyte_fil, if_cpb_pump_suckers_used,
    avalon_cannula, target_flow_rate, time_of_ecls,
    target_act, total_heparin_dose,
    nadir_temperature, nadir_hct,
    cell_salvage, units_rbc_intraop, units_ffp_intraop,
    units_of_platelets, units_of_cryoprecipitate,
    total_amount_of_fluids_use,
    type_of_pressor_used___0, type_of_pressor_used___1,
    type_of_pressor_used___2, type_of_pressor_used___3,
    type_of_pressor_used___4, type_of_pressor_used___5,
    type_of_pressor_used___6, type_of_pressor_used___7,
    use_of_inhaled_vasodilator,
    intraoperative_ecls, type_of_ecls_used,
    was_there_a_conversion, type_of_ecls_conversion,
    postoperative_ecls,
    total_fluids_in_first_24_h, type_of_post_op_fluids_in
  )

vars_t1 <- setdiff(names(t1_df), "aki_binary")

# Make outcome a 2-level factor; drop empty levels
uv_df <- t1_df %>%
  mutate(
    # ensure outcome is a factor with two levels
    aki_binary = if (is.factor(aki_binary)) fct_drop(aki_binary) else
      factor(aki_binary, levels = c(0,1), labels = c("No AKI","AKI"))
  ) %>%
  mutate(across(where(is.factor), fct_drop))

# Keep only predictors with variation
has_variation <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) == 0) return(FALSE)
  if (is.factor(x)) nlevels(x) >= 2 else dplyr::n_distinct(x) >= 2
}
vars_ok <- vars_t1[sapply(uv_df[vars_t1], has_variation)]

# see what was excluded for debug only
#excluded <- setdiff(vars_t1, vars_ok)
#if (length(excluded)) message("Excluded (no variation or all NA): ", paste(excluded, collapse = ", "))

# Univariate logistic regression on the Table-1 set
univariate_results <- uv_df %>%
  select(aki_binary, all_of(vars_ok)) %>%
  tbl_uvregression(
    method = glm,
    y = aki_binary,
    method.args = list(family = binomial),
    exponentiate = TRUE,
    pvalue_fun = ~ style_pvalue(.x, digits = 3)
  ) %>%
  bold_p(0.05) %>%
  bold_labels()

univariate_results
