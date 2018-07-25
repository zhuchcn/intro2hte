library(Metabase)
# -------- read data -----------------------------------------------------------
file = "data/302870_Zhu_CSH-QTOF_lipidomics.xlsx"
mset = import_wcmc_excel(
    file            = file, 
    sheet           = "Submit",
    conc_range      = "I10:BA613",
    sample_range    = "H1:BA9",
    feature_range   = "A9:H613",
    InChIKey        = "InChI Key",
    experiment_type = "Lipidomics"
)
# -------- remove unannotated features -----------------------------------------
mset = subset_features(mset, !is.na(feature_data(mset)$InChIKey))
# -------- seummarize qc -------------------------------------------------------
mset = collapse_QC(mset, qc_names = paste0("Biorec00", 1:5))
# -------- filter out or fill up NAs -------------------------------------------
plot_hist_NA(mset)
mset = subset_features(
    mset, apply(conc_table(mset), 1, function(x) sum(is.na(x)) < 5) )
mset = transform_by_feature(
    mset, function(x) ifelse(is.na(x), min(x, na.rm = TRUE)/2, x)
)
# -------- calibration to internal standards -----------------------------------
internal_standards = read.csv("data/wcmc_lipidomics_standards.csv")
feature_data(mset)$class = assign_lipid_class(feature_data(mset)$Annotation)
feature_data(mset)$ESI = ifelse(grepl("\\+$", feature_data(mset)$Species),
                                "pos", "neg")
experiment_data(mset)$institute = "West Coast Metabolomics Center"
experiment_data(mset)$sample_volumn_ul = 20
experiment_data(mset)$internal_standards = internal_standards
experiment_data(mset)
mset = calibrate_lipidomics_wcmc(mset, cid = "InChIKey", 
                                 class = "class", ESI = "ESI")
# -------- if detected in both modes, keep the one with lower cv ---------------
mset = filter_by_cv(mset, cv = "qc_cv", cid = "InChIKey")
plot_qc(mset, mean = "qc_mean", sd = "qc_sd", cv = "qc_cv")
plot_boxplot(mset, x = "Timepoint", feature = "Feature033", cols = "Treatment", 
             color = "Subject", line = "Subject")