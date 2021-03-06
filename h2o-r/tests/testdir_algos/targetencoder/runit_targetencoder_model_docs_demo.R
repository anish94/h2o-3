setwd(normalizePath(dirname(R.utils::commandArgs(asValues=TRUE)$"f")))
source("../../../scripts/h2o-r-test-setup.R")

test.model.targetencoder <- function() {
    test_that_te_is_helpful_for_titanic_gbm_xval <- function() {
        f <- "https://s3.amazonaws.com/h2o-public-test-data/smalldata/gbm_test/titanic.csv"
        titanic <- h2o.importFile(f)

        # Set response column as a factor
        response <- "survived"
        titanic[response] <- as.factor(titanic[response])

        seed=1234
        splits <- h2o.splitFrame(titanic, seed = seed, ratios = c(0.8), destination_frames = c("train", "test"))

        train <- splits[[1]]
        test <- splits[[2]]

        # Choose which columns to encode
        encoded_columns <- c('home.dest', 'cabin', 'embarked')

        train$fold <- h2o.kfold_column(train, nfolds = 5, seed = 3456)

        blended_avg = TRUE
        inflection_point = 3
        smoothing = 10
        # In general, the less data you have the more regularisation you need
        noise = 0.15

        target_encoder <- h2o.targetencoder(training_frame = train, x = encoded_columns, y = "survived",
                                            fold_column="fold", data_leakage_handling="KFold",
                                            blending=blended_avg, k=inflection_point, f=smoothing, noise=noise)

        transformed_train <- h2o.transform(target_encoder, train, data_leakage_handling="KFold", noise=noise)
        transformed_test <- h2o.transform(target_encoder, test, noise=0.0)

        ignored_columns <- c("boat", "ticket", "name", "body")
        features_with_te <- setdiff(setdiff(setdiff(names(transformed_train), response), encoded_columns), ignored_columns)
        print(features_with_te)

        gbm_with_te <- h2o.gbm(x = features_with_te,
                               y = response,
                               training_frame = transformed_train,
                               fold_column="fold",
                               score_tree_interval=5,
                               ntrees = 10000,
                               max_depth = 6,
                               min_rows = 1,
                               sample_rate=0.8,
                               col_sample_rate=0.8,
                               seed=1234,
                               stopping_rounds=5,
                               stopping_metric="auto",
                               stopping_tolerance=0.001,
                               model_id="gbm_with_te")

        with_te_test_predictions <- predict(gbm_with_te, transformed_test)

        print(with_te_test_predictions)

        print(paste0("TE GBM AUC TRAIN: ", round(h2o.auc(h2o.performance(gbm_with_te, transformed_train)), 5)))
        print(paste0("TE GBM AUC TEST: ", round(h2o.auc(h2o.performance(gbm_with_te, transformed_test)), 5)))


        # Baseline gbm
        features <- setdiff(setdiff(names(train), response), ignored_columns)

        gbm_baseline <- h2o.gbm(x = features,
                                y = response,
                                training_frame = train,
                                fold_column="fold",
                                score_tree_interval=5,
                                ntrees = 10000,
                                max_depth = 6,
                                min_rows = 1,
                                sample_rate=0.8,
                                col_sample_rate=0.8,
                                seed=1234,
                                stopping_rounds=5,
                                stopping_metric="auto",
                                stopping_tolerance=0.001,
                                model_id="gbm_baseline")

        baseline_test_predictions <- predict(gbm_baseline, test)

        print(baseline_test_predictions)

        print(paste0("GBM AUC TRAIN: ", round(h2o.auc(h2o.performance(gbm_baseline, train)), 5)))
        print(paste0("GBM AUC TEST: ", round(h2o.auc(h2o.performance(gbm_baseline, test)), 5)))

    }

    makeSuite(
        test_that_te_is_helpful_for_titanic_gbm_xval
    )
}

doSuite("Target Encoder Model demo for docs test", test.model.targetencoder(), time_monitor=TRUE)
