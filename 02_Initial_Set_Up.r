# Final Project 02_Initial_Set_Up.r ----
# Initial data checks, data splitting, & data folding
 
# load packages ----
library(tidyverse)
library(tidymodels) 
library(here)

# handle common conflicts
tidymodels_prefer()

# load data
crash_data <- read_rds(here("data/processed/traffic_crashes_tidy.rds")) 

set.seed(301)
# Splitting the data
crash_split <- initial_split(crash_data, prop = 0.8, strata = injuries_total_grouped)
crash_train <- training(crash_split)
crash_test <- testing(crash_split)

dim(crash_train)
dim(crash_test)

# R Data File (.rda)
save(crash_train, crash_test, file = here("splits/crash_split.rda"))

# folding
crash_folds <-
  vfold_cv(crash_train, v = 5, repeats = 3, strata = injuries_total_grouped)

save(crash_folds, file = here("splits/crash_folds.rda")) 

crash_train |> 
  ggplot(aes(x = (injuries_total_grouped))) + 
  geom_bar() +
  labs(
    title = "Distribution of Total Number of Injuires",
    x = "Total Number of Injuires", 
    y = "Count"
  )

