# Final Project  
# Define and fit baseline models (null and naive bayes)

# load packages ----
library(tidyverse) 
library(tidymodels)
library(here)
library(discrim)
library(klaR)
library(future)

# handle common conflicts
tidymodels_prefer()

# parallel processing ----
num_cores <- parallel::detectCores(logical = TRUE)/2
plan(multisession, workers = num_cores)

# load objects
load(here("recipes/crash_recipes.rda"))
load(here("splits/crash_folds.rda"))

# Null Model ---
null_spec <- null_model() |>
  set_engine("parsnip") |>
  set_mode("classification") 

null_workflow <- workflow() |> 
  add_model(null_spec) |>
  add_recipe(crash_recipe_lm)

null_fit <- null_workflow |> 
  fit_resamples(
    resamples = crash_folds, 
    control = control_resamples(save_workflow = TRUE)
  ) 

save(null_fit, file = here("results/crash_baseline_fits.rda"))
