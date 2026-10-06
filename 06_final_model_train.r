# Final Project 06_final_model_train.r
# Train final model

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(doMC)
library(future)
library(themis)

# handle common conflicts
tidymodels_prefer()

# parallel processing ----
num_cores <- parallel::detectCores(logical = TRUE)/2
plan(multisession, workers = num_cores)

# load objects ----
load(here("splits/crash_split.rda"))
load(here("results/elastic_tuned_balanced.rda"))

# finalize workflow
final_wkflow <- extract_workflow(elastic_tuned_balanced) |> 
  finalize_workflow(select_best(elastic_tuned_balanced, metric = "roc_auc"))

set.seed(301)
# fit best model
final_fit <- fit(final_wkflow, crash_train)

save(final_fit, file = here("results/final_fit.rda"))