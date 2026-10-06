# Final Project 04d_knn_fit.r
# Define and fit knn model

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
knn_spec <- nearest_neighbor(
  neighbors = tune()
) |>
  set_engine("kknn") |> 
  set_mode("classification")

# define workflows unbalanced----
knn_wkflow <- workflow() |> 
  add_model(knn_spec) |> 
  add_recipe(crash_recipe_lm)

# define workflows balanced ----
knn_wkflow_balanced <- workflow() |> 
  add_model(knn_spec) |> 
  add_recipe(crash_recipe_lm_balanced)

# hyperparameter tuning values ----
knn_params <- extract_parameter_set_dials(knn_spec) |> 
  update(neighbors = neighbors(range = c(2, 10)))

# create grid on parameters
knn_grid <- grid_regular(knn_params, levels = 10)

set.seed(301)
# fit workflows/models ----
knn_tuned <- tune_grid(
  knn_wkflow, 
  resamples = crash_folds,
  grid = knn_grid, 
  control = control_grid(save_workflow = TRUE)
)

save(knn_tuned, file = here("results/knn_tuned.rda"))

# fit workflows/models ----
knn_tuned_balanced <- tune_grid(
  knn_wkflow_balanced, 
  resamples = crash_folds,
  grid = knn_grid, 
  control = control_grid(save_workflow = TRUE)
)

# write out results (fitted/trained workflows) ----
save(knn_tuned_balanced, file = here("results/knn_tuned_balanced.rda"))