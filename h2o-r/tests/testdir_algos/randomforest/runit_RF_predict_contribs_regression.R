setwd(normalizePath(dirname(R.utils::commandArgs(asValues=TRUE)$"f")))
source("../../../scripts/h2o-r-test-setup.R")



test.DRF.contribs_regression <- function() {

    # Check using all columns as input
    prostate_hex <- h2o.importFile(locate("smalldata/prostate/prostate.csv"))
    prostate_hex$CAPSULE <- as.factor(prostate_hex$CAPSULE)

    drf_model <- h2o.randomForest(training_frame = prostate_hex, y = "VOL")

    predicted <- as.data.frame(h2o.predict(drf_model, prostate_hex))
    contributions <- as.data.frame(h2o.predict_contributions(drf_model, prostate_hex))

    pred_using_contributions <- rowSums(contributions)
    
    expect_equal(predicted$predict, pred_using_contributions, tolerance = 1e-6)

    # Check using all columns as input except "AGE"
    prostate_hex <- h2o.importFile(locate("smalldata/prostate/prostate.csv"))
    prostate_hex$CAPSULE <- as.factor(prostate_hex$CAPSULE)

    drf_model <- h2o.randomForest(training_frame = prostate_hex, x = setdiff(names(prostate_hex), c("AGE")), y = "VOL")

    predicted <- as.data.frame(h2o.predict(drf_model, prostate_hex))
    contributions <- as.data.frame(h2o.predict_contributions(drf_model, prostate_hex))

    pred_using_contributions <- rowSums(contributions)

    expect_equal(predicted$predict, pred_using_contributions, tolerance = 1e-6)

    # Check using only "AGE"
    prostate_hex <- h2o.importFile(locate("smalldata/prostate/prostate.csv"))
    prostate_hex$CAPSULE <- as.factor(prostate_hex$CAPSULE)

    drf_model <- h2o.randomForest(training_frame = prostate_hex, x="AGE", y = "VOL")

    predicted <- as.data.frame(h2o.predict(drf_model, prostate_hex))
    contributions <- as.data.frame(h2o.predict_contributions(drf_model, prostate_hex))

    pred_using_contributions <- rowSums(contributions)

    expect_equal(predicted$predict, pred_using_contributions, tolerance = 1e-6)
}

doTest("DRF Test: Make sure DRF contributions correspond to predictions for regression models", test.DRF.contribs_regression)
