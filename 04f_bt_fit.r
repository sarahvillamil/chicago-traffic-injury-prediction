# Final Project 04f_bt_fit.r
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
bt_spec <- boost_tree(
  min_n = tune(), 
  mtry = tune(), 
  learn_rate = tune(), 
  trees = tune()
) |>
  set_engine("xgboost") |> 
  set_mode("classification")

# define workflows unbalanced----
bt_wkflow <- workflow() |> 
  add_model(bt_spec) |> 
  add_recipe(crash_recipe_tree)

# define workflows balanced----
bt_wkflow_balanced <- workflow() |> 
  add_model(bt_spec) |> 
  add_recipe(crash_recipe_tree_balanced)

# hyperparameter tuning values ----
bt_params <- extract_parameter_set_dials(bt_spec) |> 
  update(min_n = min_n(range = c(2,20)), 
          mtry = mtry(c(1, 10)), 
          learn_rate = learn_rate(range = c(-5, 0.4)), 
          trees = trees(range = c(250, 750)), 
         )

# create grid on parameters
bt_grid <- grid_regular(bt_params, levels = c(5, 3, 3, 5))

set.seed(301)
# fit workflows/models unbalanced ----
bt_tuned <- tune_grid(
  bt_wkflow, 
  resamples = crash_folds,
  grid = bt_grid, 
  control = control_grid(save_workflow = TRUE)
)

save(bt_tuned, file = here("results/bt_tuned.rda"))

# fit workflows/models balanced----
bt_tuned_balanced <- tune_grid(
  bt_wkflow_balanced, 
  resamples = crash_folds,
  grid = bt_grid, 
  control = control_grid(save_workflow = TRUE)
)

# write out results (fitted/trained workflows) ----
save(bt_tuned_balanced, file = here("results/bt_tuned_balanced.rda"))