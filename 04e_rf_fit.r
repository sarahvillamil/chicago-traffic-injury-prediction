# Final Project 04e_rf_fit.r
# Define and fit rf model

# load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(future)
library(themis)

# handle common conflicts
tidymodels_prefer() 

# parallel processing ----
num_cores <- parallel::detectCores(logical = TRUE)/2
plan(multisession, workers = num_cores)

# load objects ----
load(here("recipes/crash_recipes.rda"))
load(here("splits/crash_folds.rda"))
load(here("splits/crash_split.rda"))

# model specifications ----
rf_spec <- rand_forest(
  min_n = tune(), 
  mtry = tune(), 
  trees = tune()
  ) |>
  set_engine("ranger") |> 
  set_mode("classification")

# define workflows unbalanced----
rf_wkflow <- workflow() |> 
  add_model(rf_spec) |> 
  add_recipe(crash_recipe_tree)

# define workflows balanced ----
rf_wkflow_balanced <- workflow() |> 
  add_model(rf_spec) |> 
  add_recipe(crash_recipe_tree_balanced)

# hyperparameter tuning values ----
rf_params <- extract_parameter_set_dials(rf_spec) |> 
  update(mtry = mtry(c(1, 10)), 
         trees = trees(range = c(250, 750)), 
         min_n = min_n(range = c(2,20)))

# create grid on parameters
rf_grid <- grid_regular(rf_params, levels = c(3, 5, 5))

set.seed(301)
# fit workflows/models unbalanced----
rf_tuned <- tune_grid(
  rf_wkflow, 
  resamples = crash_folds,
  grid = rf_grid, 
  control = control_grid(save_workflow = TRUE)
)

# write out results (fitted/trained workflows) ----
save(rf_tuned, file = here("results/rf_tuned.rda"))

# fit workflows/models balanced----
rf_tuned_balanced <- tune_grid(
  rf_wkflow_balanced, 
  resamples = crash_folds,
  grid = rf_grid, 
  control = control_grid(save_workflow = TRUE)
)

# write out results (fitted/trained workflows) ----
save(rf_tuned_balanced, file = here("results/rf_tuned_balanced.rda"))