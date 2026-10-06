# Classification Problem
# Assess final model

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# handle common conflicts
tidymodels_prefer()

load(here("results/final_fit.rda"))
load(here("splits/crash_split.rda"))

# add predictions to test data probability 
final_result_prob <- crash_test |> 
  select(injuries_total_grouped) |>
  bind_cols(predict(final_fit, crash_test, type = "prob")) |> 
  mutate(injuries_total_grouped = as.factor(injuries_total_grouped)) |> 
  rename(pred_none = .pred_none,
         pred_one = .pred_one, 
         pred_two_or_more = .pred_two_or_more)   

# dd predictions to test data class 
final_result_class <- crash_test |> 
  select(injuries_total_grouped) |>
  bind_cols(predict(final_fit, crash_test)) |> 
  mutate(injuries_total_grouped = as.factor(injuries_total_grouped)) |> 
  rename(pred = .pred_class)

# final metrics
final_metrics <- bind_rows(
  "ROC-AUC" = roc_auc(final_result_prob, injuries_total_grouped, starts_with("pred")),
  "F1 Score" = f_meas(final_result_class, injuries_total_grouped, pred), 
  "Precision" = precision(final_result_class, injuries_total_grouped, pred), 
  "Accuracy" = accuracy(final_result_class, injuries_total_grouped, pred), 
  "Recall" = recall(final_result_class, injuries_total_grouped, pred),  .id = "Metric") |> 
  select(-c(.estimator, .metric)) |>
  arrange(desc(.estimate)) |>
  rename(`Estimate` = .estimate) |> 
  knitr::kable(digits = c(NA, 3, 4, 0)) 
  
save(final_metrics, file = here("results/final_metrics.rda"))


# final metrics
final_roc_auc<- bind_rows(
  "ROC-AUC" = roc_auc(final_result_prob, injuries_total_grouped, starts_with("pred")), .id = "Metric") |> 
  select(-c(.estimator, .metric)) |>
  rename(`Estimate` = .estimate) |> 
  knitr::kable(digits = c(NA, 3, 4, 0)) 

save(final_roc_auc, file = here("results/final_roc_auc.rda"))

# roc_curve
final_roc_curve <- roc_curve(final_result, injuries_total_grouped, starts_with("pred")) |>
  autoplot() + theme_bw() + labs(
    title = "ROC Curve of Total Number of Injuries for Final Prediction Model", 
    y = "True Positive Rate", 
    x = "False Positive Rate"
  )

save(final_roc_curve, file = here("results/final_roc_curve.rda"))

# conf mat
final_conf_mat <- conf_mat(final_result_class, injuries_total_grouped, pred) |>
  autoplot(type = "heatmap") + theme_bw() +
  labs(
    title = "Confusion Matrix of Total Number of Injuries for Final Prediction Model", 
    x = "True Value", 
    y = "Predicted Value", 
  ) +
 theme(legend.position = "none") +
  scale_fill_gradient(low = "whitesmoke", high = "darkcyan")

save(final_conf_mat, file = here("results/final_conf_mat.rda"))
