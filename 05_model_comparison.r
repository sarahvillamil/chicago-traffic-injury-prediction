# Final Project 05_model_comparison.r
# Model selection/comparison & analysis

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)

# handle common conflicts
tidymodels_prefer()

load(here("results/crash_baseline_fits.rda"))
load(here("results/multinom_tuned.rda"))
load(here("results/multinom_tuned_balanced.rda"))
load(here("results/elastic_tuned_both.rda"))
load(here("results/elastic_tuned_balanced.rda"))
load(here("results/bt_tuned.rda"))
load(here("results/bt_tuned_balanced.rda"))
load(here("results/rf_tuned.rda"))
load(here("results/rf_tuned_balanced.rda"))
load(here("results/knn_tuned.rda"))
load(here("results/knn_tuned_balanced.rda"))

# put all model together in workflow set
model_results <- as_workflow_set(
  null = null_fit,
  rf = rf_tuned,
  rf_balanced = rf_tuned_balanced,
  knn = knn_tuned,
  knn_balanced = knn_tuned_balanced,
  elastic = elastic_tuned,
  elastic_balanced = elastic_tuned_balanced,
  multinom = multinom_tuned, 
  multinom_balanced = multinom_tuned_balanced, 
  bt = bt_tuned, 
  bt_balanced = bt_tuned_balanced, 
)

# get all model results
model_comparison <- model_results |> 
  collect_metrics() |>
  filter(.metric == "roc_auc") |> 
  slice_max(mean, by = wflow_id) |> 
  arrange(desc(mean)) |> 
  select(`Model Type` = wflow_id, `Roc-Auc` = mean, `Std Error` = std_err, n) |> 
  knitr::kable(digits = c(NA, 3, 4, 0))

save(model_comparison, file = here("results/model_comparison.rda"))

# autoplots
# should have expanded the tuning to be until 1 because the best value of 
# penalty parameter happens between 0.01 and 1. 
multinom_autoplot <- autoplot(multinom_tuned, metric = "roc_auc") +
  theme_bw() +
  labs(title = "Autoplot for Imbalanced Multinomial Regression's Hyperparameters")

# should have expanded the tuning to be until 1 because the best value of 
# penalty parameter happens super close right before one. 
multinom_balanced_autoplot <- autoplot(multinom_tuned_balanced, metric = "roc_auc") +
  theme_bw() +
  labs(title = "Autoplot for Balanced Multinomial Regression's Hyperparameters")

# the right range was explored for these parameters as shown in the autoplot. 
# As the parameter's values increase, it's roc-auc worsens. For both of them. 
elastic_autoplot <- autoplot(elastic_tuned, metric = "roc_auc") +
  theme_bw() +
  labs(title = "Autoplot for Imbalanced Elastic Net's Hyperparameters")

elastic_balanced_autoplot <- autoplot(elastic_tuned_balanced, metric = "roc_auc") +
  theme_bw() +
  labs(title = "Autoplot for Balanced Elastic Net's Hyperparameters")

# the autoplot shows an increasing trend beyond the range of 10 nearest neighbors. 
# If this fit was tuned again, I would give the parameter a much higher range 
# as I suspect the reason it has such a low roc-auc is due to a poorly picked 
# tuning parameter. For both. 
knn_autoplot <- autoplot(knn_tuned, metric = "roc_auc") +
  theme_bw() +
  labs(title = "Autoplot for Imbalanced Nearest Neighbors's Hyperparameters")

knn_balanced_autoplot <- autoplot(knn_tuned_balanced, metric = "roc_auc") +
  theme_bw() +
  labs(title = "Autoplot for Balanced Nearest Neighbors's Hyperparameters")

# For random forest model, I would keep the mtry tuning range the same as the best 
# parameter happened at five and significantly decreased at 10. For the number of trees, 
# I would maybe increase the tuning parameter by 50 or 100. Even though the best 
# parameter does not fall at the upper edge of the range, it still shows a 
# promising increase in the autoplot that I would be interested in exploring. 
# For min_n, I would defintely retune with a larger range. It is clear that 20 is the best
# value for the parameter within the autoplot and leaves me to wonder if the 
# value was increased if it would result in a better performing roc-auc. 
rf_autoplot <- autoplot(rf_tuned, metric = "roc_auc") +
  theme_bw() +
  labs(title = "Autoplot for Imbalanced Random Forest's Hyperparameters")

# For the balanced random forest model, I would increase the mtry tuning range as 
# 10 worked better than five in this circumstance and it seems as if the values increase
# so will it's roc_auc performance metric. For the trees, I would not increase the range 
# because on the autoplot, the tree parameter does not seem to be causing 
# significant difference to the roc-auc as the number of trees increase. 
# I would play with increasing the min_n tuning range as with the imbalanced fit as 
# there might be room for a better performing parameter value beyond 20 as teased 
# in the autoplot. 
rf_balanced_autoplot <- autoplot(rf_tuned_balanced, metric = "roc_auc") +
  theme_bw() +
  labs(title = "Autoplot for Balanced Random Forest's Hyperparameters")

# For the imbalanced boosted model tree, I would keep the all hyper paramtere's tuning ranges for 
# mtry, trees, min_n, and learning rate the same. 
# There is consistent results across the differentiating values for each of these 
# parameters and no promising sign in an increase in roc-auc if the range in adjusted. 
bt_autoplot <- autoplot(bt_tuned, metric = "roc_auc") +
  theme_bw() +
  labs(title = "Autoplot for Imbalanced Boosted Tree's Hyperparameters")

# For the balanced boosted tree model, I would increase the range of mtry as depending on 
# the value of the learning rate, some of the roc-auc continue to increase as the mtry 
# reaches 10 and seems to continue to grow beyond it. I would also increase min_n as
# the autoplot shows a potential better parameter as the range increases beyond 20. 
# I would keep trees and learning rate ranges the same as no promising sign of an increase 
# in roc-auc if the range in adjusted.
bt_balanced_autoplot <-autoplot(bt_tuned_balanced, metric = "roc_auc") +
  theme_bw() +
  labs(title = "Autoplot for Balanced Boosted Tree's Hyperparameters")

save(multinom_autoplot, multinom_balanced_autoplot, elastic_autoplot, elastic_balanced_autoplot, 
     knn_autoplot, knn_balanced_autoplot, rf_autoplot, rf_balanced_autoplot, bt_autoplot, 
     bt_balanced_autoplot,
     file = here("results/autoplots.rda"))

# best parameters
best_multinom_tuned <- select_best(multinom_tuned, metric = "roc_auc")
select_best(multinom_tuned_balanced, metric = "roc_auc")

select_best(elastic_tuned, metric = "roc_auc")
select_best(elastic_tuned_balanced, metric = "roc_auc")

select_best(knn_tuned, metric = "roc_auc")
select_best(knn_tuned_balanced, metric = "roc_auc")

select_best(rf_tuned, metric = "roc_auc")
select_best(rf_tuned_balanced, metric = "roc_auc")

select_best(bt_tuned, metric = "roc_auc")
select_best(bt_tuned_balanced, metric = "roc_auc")
  
best_model_parameters <- bind_rows(
  "Multinom"= select_best(multinom_tuned, metric = "roc_auc"), 
  "Multinom Balanced" = select_best(multinom_tuned_balanced, metric = "roc_auc"),
  "Elastic" = select_best(elastic_tuned, metric = "roc_auc"),
  "Elastic Balanced" = select_best(elastic_tuned_balanced, metric = "roc_auc"),
  "KNN" = select_best(knn_tuned, metric = "roc_auc"),
  "KNN Balanced"= select_best(knn_tuned_balanced, metric = "roc_auc"),
  "RF" = select_best(rf_tuned, metric = "roc_auc"),
  "RF Balanced" = select_best(rf_tuned_balanced, metric = "roc_auc"),
  "BT" = select_best(bt_tuned, metric = "roc_auc"),
  "BT Balanced" = select_best(bt_tuned_balanced, metric = "roc_auc"), .id = "Model"
  ) |> select(-.config) |>
  pivot_longer(cols = -Model, 
               names_to = "Parameter",
               values_to = "Best Value Value",
               values_drop_na = TRUE) |>
  rename(`Model Type` = Model) |> 
  knitr::kable(digits = c(NA, 3, 4, 0))

save(best_model_parameters, file = here("results/best_model_parameters.rda"))
  

