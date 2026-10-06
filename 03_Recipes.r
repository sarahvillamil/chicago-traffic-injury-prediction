# Final Project 03_Recipes.r ----
# Recipes
   
# load packages ----
library(tidyverse)
library(tidymodels)
library(here)
library(themis)

# handle common conflicts
tidymodels_prefer()

# load objects
load(here("splits/crash_split.rda"))

# kitchen sink recipe ----
crash_recipe_lm <- recipe(injuries_total_grouped ~ crash_day_of_week + crash_hour + crash_month + 
                            street_direction + damage +
                            roadway_surface_cond + lane_cnt + trafficway_type +
                            first_crash_type + lighting_condition + 
                            weather_condition + device_condition + traffic_control_device + 
                            posted_speed_limit + street_no, data = crash_train) |>
  step_impute_knn(lane_cnt) |>
  step_dummy(all_nominal_predictors()) |>  
  step_interact(~starts_with("damage"):crash_hour + starts_with("damage"):posted_speed_limit) |>
  step_zv(all_predictors()) |> 
  step_normalize(all_numeric_predictors())

# check recipe
crash_lm_check <- crash_recipe_lm |> 
  prep() |> 
  bake(new_data = NULL)

# rebalanced lm recipe ----
crash_recipe_lm_balanced <- recipe(injuries_total_grouped ~ crash_day_of_week + crash_hour + crash_month + 
                            street_direction + damage +
                            roadway_surface_cond + lane_cnt + trafficway_type +
                            first_crash_type + lighting_condition + 
                            weather_condition + device_condition + traffic_control_device + 
                            posted_speed_limit + street_no, data = crash_train) |>
  step_impute_knn(lane_cnt) |>
  step_dummy(all_nominal_predictors()) |>  
  step_interact(~starts_with("damage"):crash_hour + starts_with("damage"):posted_speed_limit) |>
  step_downsample(injuries_total_grouped) |>
  step_zv(all_predictors()) |> 
  step_normalize(all_numeric_predictors())  
  

# check recipe
crash_lm_balanced_check <- crash_recipe_lm_balanced |> 
  prep() |> 
  bake(new_data = NULL)

# visualization of rebalance
crash_lm_balanced_check |> 
  ggplot(aes(x = (injuries_total_grouped))) + 
  geom_bar() +
  labs(
    title = "Distribution of Total Number of Injuires Balanced",
    x = "Total Number of Injuires", 
    y = "Count"
  )

distribution_balanced <- crash_lm_balanced_check |> 
  group_by(injuries_total_grouped) |> 
  count() |> 
  rename(`Total Number of Injuries` = injuries_total_grouped, `Count` = n) |>
  knitr::kable(digits = c(NA, 3, 4, 0))

save(distribution_balanced, file = here("results/eda/distribution_balanced.rda"))

# tree-based recipe ----
crash_recipe_tree <- recipe(injuries_total_grouped ~ crash_day_of_week + crash_hour + crash_month + 
                              street_direction + damage +
                              roadway_surface_cond + lane_cnt + trafficway_type +
                              first_crash_type + lighting_condition + 
                              weather_condition + device_condition + traffic_control_device + 
                              posted_speed_limit + street_no, data = crash_train) |>
  step_impute_knn(lane_cnt) |>
  step_dummy(all_nominal_predictors(), one_hot = TRUE) |> 
  step_interact(~starts_with("damage"):crash_hour + starts_with("damage"):posted_speed_limit) |>
  step_zv(all_predictors())

# check recipe
crash_tree_check <-crash_recipe_tree |> 
  prep() |> 
  bake(new_data = NULL)

# rebalanced tree recipe ----
crash_recipe_tree_balanced <- recipe(injuries_total_grouped ~ crash_day_of_week + crash_hour + crash_month + 
                                        street_direction + damage +
                                        roadway_surface_cond + lane_cnt + trafficway_type +
                                        first_crash_type + lighting_condition + 
                                        weather_condition + device_condition + traffic_control_device + 
                                        posted_speed_limit + street_no, data = crash_train) |>
  step_impute_knn(lane_cnt) |>
  step_dummy(all_nominal_predictors(), one_hot = TRUE) |> 
  step_interact(~starts_with("damage"):crash_hour + starts_with("damage"):posted_speed_limit) |>
  step_zv(all_predictors()) |>
  step_downsample(injuries_total_grouped)

# check recipe
crash_tree_check_balanced <- crash_recipe_tree_balanced |> 
  prep() |> 
  bake(new_data = NULL)

# save recipes
save(crash_recipe_lm, crash_recipe_lm_balanced, crash_recipe_tree, crash_recipe_tree_balanced, file = here("recipes/crash_recipes.rda"))
