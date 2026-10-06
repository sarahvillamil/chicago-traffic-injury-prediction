# Final Project 04b_logis_reg_fit.r
# Define and fit multinomial model

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
multinom_spec <- multinom_reg(
  penalty = tune()) |> 
  set_engine("nnet") |> 
  set_mode("classification")

# define workflows unbalanced ----
multinom_wkflow <- workflow() |> 
  add_model(multinom_spec) |> 
  add_recipe(crash_recipe_lm)

# define workflows balanced----
multinom_wkflow_balanced <- workflow() |> 
  add_model(multinom_spec) |> 
  add_recipe(crash_recipe_lm_balanced)

# hyperparameter tuning values ----
multinom_params <- extract_parameter_set_dials(multinom_spec) |> 
  update(penalty = penalty(range = c(-5, -0.2)))

# create grid on parameters
multinom_grid <- grid_regular(multinom_params, levels = 10)

set.seed(301)
# fit workflows/models unbalanced 
multinom_tuned <- tune_grid(
  multinom_wkflow, 
  resamples = crash_folds,
  grid = multinom_grid, 
  control = control_grid(save_workflow = TRUE)
)

save(multinom_tuned, file = here("results/multinom_tuned.rda"))

# fit workflows/models balanced 
multinom_tuned_balanced <- tune_grid(
  multinom_wkflow_balanced, 
  resamples = crash_folds,
  grid = multinom_grid, 
  control = control_grid(save_workflow = TRUE)
)

# write out results (fitted/trained workflows) ----
save(multinom_tuned_balanced, file = here("results/multinom_tuned_balanced.rda"))
