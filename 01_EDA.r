# Final Project  
# 01 Memo 1 data analysis 
 
# load libraries
library(tidyverse)
library(naniar)
library(here)
 
# load data
traffic_crashes_raw <-read_csv(here("data/raw/traffic_crashes_raw.csv")) |> 
  janitor::clean_names()

# EDA
traffic_crashes_raw |> 
  skimr::skim_without_charts()

missingness_overall <- traffic_crashes_raw|>
  gg_miss_var() + 
  labs(
    title = "General Missingness in Chicago's Car Crashes's Data",
    subtitle = "Collected by City of Chicago")

missingness_top <- traffic_crashes_raw |> 
  miss_var_summary() |>
  filter(n_miss > 20) 

missingness_top <- traffic_crashes_raw |> 
  miss_var_summary() |>
  filter(pct_miss > 50) |>  
  rename(`Percent Missed` = pct_miss, `Number Missed` = n_miss, `Variable` = variable) |>
  knitr::kable(digits = c(NA, 3, 4, 0))

save(missingness_top, file = here("results/eda/missingness_top.rda"))

knitr::kable(missingness_top, caption = "Top Missingness of
             Variables in Chicago Crash Data")
# box plot to show why I choose the predcitors
# Transforming the variable into factors to make it classification and not regression. 
set.seed(301)

traffic_crashes_tidy <- traffic_crashes_raw |> 
  mutate(injuries_total_grouped = case_when(
    injuries_total == 0 ~ "none",
    injuries_total == 1 ~ "one",
    injuries_total > 1 ~ "two_or_more"), 
    street_name = as.factor(street_name),
    traffic_control_device = as.factor(traffic_control_device), 
    device_condition = as.factor(device_condition), 
    first_crash_type = as.factor(first_crash_type), 
    weather_condition = as.factor(weather_condition)
    ) |> 
  drop_na(injuries_total_grouped) |>
  slice_sample(prop = 0.03, by = injuries_total_grouped)

traffic_crashes_tidy <- write_rds(traffic_crashes_tidy, "data/processed/traffic_crashes_tidy.rds")

traffic_crashes_tidy |> 
  drop_na(injuries_total_grouped) |>
  ggplot(aes(x = (injuries_total_grouped))) + 
  geom_bar() +
  labs(
    title = "Distribution of Total Number of Injuires",
    x = "Total Number of Injuires", 
    y = "Count"
  )

missingness_overall <- traffic_crashes_tidy |> 
  select(injuries_total_grouped, crash_day_of_week, crash_hour, crash_month, street_direction, 
         damage, roadway_surface_cond, lane_cnt, trafficway_type, first_crash_type,
         lighting_condition, weather_condition, device_condition, 
         traffic_control_device, posted_speed_limit, street_no) |>
  gg_miss_var() + 
  labs(
    title = "General Missingness in Chicago's Car Crashes's Data",
    subtitle = "Collected by City of Chicago")


# EDA of predictors  ------------------------------------------------------
traffic_crashes_tidy |> 
  ggplot(aes(x = injuries_total_grouped, y = crash_month)) + 
  geom_col(fill = "darkcyan") +
  facet_wrap(~crash_month) +
  labs(
    title = "Relationship Between Total Number of Injuries and Crash Month",
    subtitle = "Month 1 Corresponds with January and so on",
    x = "Total Number of Injuries", 
    y = "Count"
  )

traffic_crashes_tidy |> 
  ggplot(aes(x = injuries_total_grouped, y = street_direction)) + 
  geom_col(fill = "darkcyan") +
  facet_wrap(~street_direction, scales = "free_y") +
  labs(
    title = "Relationship Between Total Number of Injuries and Street Direction",
    x = "Total Number of Injuries", 
    y = "Count"
  )

traffic_crashes_tidy |> 
  ggplot(aes(x = (injuries_total_grouped), y = trafficway_type)) + 
  geom_col() +
  facet_wrap(~trafficway_type)
  
traffic_crashes_tidy |> 
    ggplot(aes(x = (injuries_total_grouped), y = crash_day_of_week)) + 
    geom_col() +
    facet_wrap(~crash_day_of_week)

# not able to facet due to large number of levels within crash_hour
traffic_crashes_tidy |> 
  ggplot(aes(x = (injuries_total_grouped), y = crash_hour)) + 
  geom_col() 

traffic_crashes_tidy |> 
  ggplot(aes(x = (injuries_total_grouped), y = damage)) + 
  geom_col() +
  facet_wrap(~damage)

traffic_crashes_tidy |> 
  ggplot(aes(x = (injuries_total_grouped), y = roadway_surface_cond)) + 
  geom_col() +
  facet_wrap(~roadway_surface_cond)

traffic_crashes_tidy |> 
  ggplot(aes(x = (injuries_total_grouped), y = lane_cnt)) + 
  geom_col() +
  facet_wrap(~lane_cnt)

traffic_crashes_tidy |> 
  ggplot(aes(x = (injuries_total_grouped), y = trafficway_type)) + 
  geom_col() +
  facet_wrap(~trafficway_type)

traffic_crashes_tidy |> 
  ggplot(aes(x = (injuries_total_grouped), y = first_crash_type)) + 
  geom_col() +
  facet_wrap(~first_crash_type)

traffic_crashes_tidy |> 
  ggplot(aes(x = (injuries_total_grouped), y = weather_condition)) + 
  geom_col() +
  facet_wrap(~weather_condition)

traffic_crashes_tidy |> 
  ggplot(aes(x = (injuries_total_grouped), y = device_condition)) + 
  geom_col() +
  facet_wrap(~device_condition)

traffic_crashes_tidy |> 
  ggplot(aes(x = (injuries_total_grouped), y = traffic_control_device)) + 
  geom_col() +
  facet_wrap(~traffic_control_device)

traffic_crashes_tidy |> 
  ggplot(aes(x = (injuries_total_grouped), y = posted_speed_limit)) + 
  geom_col() +
  facet_wrap(~posted_speed_limit)

traffic_crashes_tidy |> 
  ggplot(aes(x = (injuries_total_grouped), y = street_no)) + 
  geom_boxplot() 

# EDA for recipes  ------------------------------------------------------
traffic_crashes_tidy |>
  ggplot(aes(x = damage, y = crash_hour)) + 
  geom_col(fill = "darkcyan") +
  facet_wrap(~crash_hour, nrow = 4) +
  theme(axis.text.x = element_text(size = 8, angle = 45, vjust = 0.5)) +
  labs(
    title = "Relationship Between Crash Hour and Damage",
    x = "Crash Hour", 
    y = "Damage"
  )

traffic_crashes_tidy |>
  filter(posted_speed_limit > 0) |> 
  ggplot(aes(x = damage, y = posted_speed_limit)) + 
  geom_col(fill = "darkcyan") +
  facet_wrap(~posted_speed_limit, ncol = 4, scales = "free_y") +
  theme(axis.text.x = element_text(size = 8, angle = 45, vjust = 0.5)) +
  labs(
    title = "Relationship Between Posted Speed Limit and Damage",
    x = "Posted Speed Limit", 
    y = "Damage"
  )

# codebook ----------------------------------------------------------------
car_crash_codebook <- tibble(
  variables = colnames(traffic_crashes_tidy),
  desciption = c("character, This number can be used to link to the same crash in the Vehicles and People datasets. This number also serves as a unique ID in this dataset.", 
                 "character, 	
Crash date estimated by desk officer or reporting party (only used in cases where crash is reported at police station days after the crash)", 
                 "character, 	
Date and time of crash as entered by the reporting officer", 
                 "double, Posted speed limit, as determined by reporting officer", 
                 "factor, Traffic control device present at crash location, as determined by reporting officer", 
                 "factor, 	
Condition of traffic control device, as determined by reporting officer", 
                 "factor: 	
Weather condition at time of crash, as determined by reporting officer", 
                 "factor, Light condition at time of crash, as determined by reporting officer",
                 "factor, Type of first collision in crash",
                 "character, 	
Trafficway type, as determined by reporting officer", 
                 "double, Total number of through lanes in either direction, excluding turn lanes, as determined by reporting officer (0 = intersection)",
                 "character, Street alignment at crash location, as determined by reporting officer",
                 "character, 	
Road surface condition, as determined by reporting officer",
                 "character, Road defects, as determined by reporting officer",
                 "character, 	
Administrative report type (at scene, at desk, amended).", 
                 "character, A general severity classification for the crash. Can be either Injury and/or Tow Due to Crash or No Injury / Drive Away", 
                 "character, 	
Whether the crash begun or first contact was made outside of the public right-of-way.",
                 "character, Crash did/did not involve a driver who caused the crash and fled the scene without exchanging information and/or rendering aid", 
                 "character, 	
A field observation of estimated damage.",
                 "character, Calendar date on which police were notified of the crash",
                 "character, The factor which was most significant in causing the crash, as determined by officer judgment",
                 "character, The factor which was second most significant in causing the crash, as determined by officer judgment",
                 "double, Street address number of crash location, as determined by reporting officer", 
                 "character, Street address direction (N,E,S,W) of crash location, as determined by reporting officer", 
                 "factor, Street address name of crash location, as determined by reporting officer", 
                 "double, Chicago Police Department Beat ID. Boundaries available at https://data.cityofchicago.org/d/aerh-rz74",
                 "character, Whether the Chicago Police Department took photos at the location of the crash.",
                 "character,	
Whether statements were taken from unit(s) involved in crash.",
                 "character, Whether crash involved a motor vehicle occupant opening a door into the travel path of a bicyclist, causing a crash",
                 "character, Whether the crash occurred in an active work zonel", 
                 "character, The type of work zone, if any", 
                 "character, Whether construction workers were present in an active work zone at crash location",
                 "double, Number of units involved in the crash. A unit can be a motor vehicle, a pedestrian, a bicyclist, or another non-passenger roadway user. Each unit represents a mode of traffic with an independent trajectory.",
                 "character, Most severe injury sustained by any person involved in the crash.", 
                 "character, Total persons sustaining fatal, incapacitating, non-incapacitating, and possible injuries as determined by the reporting officer", 
                 "double,	
Total persons sustaining fatal injuries in the crash", 
                 "double,	
Total persons sustaining incapacitating/serious injuries in the crash as determined by the reporting officer. Any injury other than fatal injury, which prevents the injured person from walking, driving, or normally continuing the activities they were capable of performing before the injury occurred. Includes severe lacerations, broken limbs, skull or chest injuries, and abdominal injuries.", 
                 "double, Total persons sustaining non-incapacitating injuries in the crash as determined by the reporting officer. Any injury, other than fatal or incapacitating injury, which is evident to observers at the scene of the crash. Includes lump on head, abrasions, bruises, and minor lacerations.",
                 "double, Total persons sustaining possible injuries in the crash as determined by the reporting officer. Includes momentary unconsciousness, claims of injuries not evident, limping, complaint of pain, nausea, and hysteria.", 
                 "double, 	
Total persons sustaining no injuries in the crash as determined by the reporting officer", 
                 "double, Total persons for whom injuries sustained, if any, are unknown", 
                 "double, 	
The hour of the day component of crash_date", 
                 "double, 	
The day of the week component of crash_date Sunday=1", 
                 "double, The month component of crash_date", 
                 "double, The latitude of the crash location, as determined by reporting officer, as derived from the reported address of crash", 
                 "double, The longitude of the crash location, as determined by reporting officer, as derived from the reported address of crash", 
                 "character, The crash location, as determined by reporting officer, as derived from the reported address of crash, in a column type that allows for mapping and other geographic analysis in the data portal software", 
                 "character, total number of injuries grouped."
  ))

write_csv(car_crash_codebook, "data/processed/car_crash_codebook.csv")

  
# notes for questions asked to Sass: 
# DONE need to set seed before slicesample or else will get diff answer each time
# need to state through eda why I chose teh 15 predictors that I showed. It could be done with a boxplot. 
# DONE then for tuning hyperparameters may need to tune more than the ones with the question mark and their ranges 
# DONE does not depend on the dataset but rather the general range of the hyperparameter
# DONE so next steps, run all recipes and fits again from the top, name all facors that need to be factors and the
# DONEwork on report while they run
# DONE Oh also for baseline models: Naive bayes recipe is used only if null not used and its needs a new recipe 
# DONE because it can't have step dummy

# more notes: 
# DONE I need Create new recipe to rebalance my classes either within feature engineering 
# DONE use F1 as my metric as accruacy is not good for unbalance data 
# DONEfor the rest of problem model building and selection, need to use autoplot 
# DONE to consider if the range for tuning the parameters should have been differet. 
# DONE Each model needs to be fitted with two different recipes: kitchen sink and one with feature engineering
# DONE Okay update: I need to create a new recipe that solves the imbalance of the data
# DONE I can still keep the original recipe as the kitchen sink and then do the imabalnce as my feature enginerring
# DONE I would then have to do f1 performance metric as an even level of comparison
# DONE I don't have to do roc_auc curve and a confusion matrix, I can chose one. 
