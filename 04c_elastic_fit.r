# Final Project 04c_elastic_fit.r
# Define and fit elastic model

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
elastic_spec <- multinom_reg(
  penalty = tune(), 
  mixture = tune()
) |> 
  set_engine("glmnet") |> 
  set_mode("classification")

# define workflows unbalanced----
elastic_wkflow <- workflow() |> 
  add_model(elastic_spec) |> 
  add_recipe(crash_recipe_lm)

# define workflows balanced----
elastic_wkflow_balanced <- workflow() |> 
  add_model(elastic_spec) |> 
  add_recipe(crash_recipe_lm_balanced)

# hyperparameter tuning values ----
elastic_params <- extract_parameter_set_dials(elastic_spec) |> 
  update(penalty = penalty(range = c(-5, -0.2)), 
         mixture = mixture(range = c(0, 1)))

# create grid on parameters
elastic_grid <- grid_regular(elastic_params, levels = 10)

set.seed(301)
# fit workflows/models unbalanced----
elastic_tuned <- tune_grid(
  elastic_wkflow, 
  resamples = crash_folds,
  grid = elastic_grid, 
  control = control_grid(save_workflow = TRUE)
)

save(elastic_tuned, file = here("results/elastic_tuned_both.rda"))

# fit workflows/models balanced----
elastic_tuned_balanced <- tune_grid(
  elastic_wkflow_balanced, 
  resamples = crash_folds,
  grid = elastic_grid, 
  control = control_grid(save_workflow = TRUE)
)

# write out results (fitted/trained workflows) ----
save(elastic_tuned_balanced, file = here("results/elastic_tuned_balanced.rda"))
