## chicago-traffic-injury-prediction
Multiclass classification of Chicago traffic crash injury severity using machine learning and R.

# Predicting Injury Severity in Chicago Traffic Crashes
 
## Overview
This project develops machine learning models to predict injury severity in Chicago traffic crashes based on roadway, environmental, and accident conditions.
 
Using over 1 million crash records from the Chicago Data Portal, I built multiclass classification models to predict whether a crash would result in no injuries, one injury, or two or more injuries.
 
## Tools
- R
- Tidymodels
- Elastic Net
- Random Forest
- Boosted Trees
- K-Nearest Neighbors
 
## Dataset
- Chicago Traffic Crashes Dataset
- 1,024,029 crash records
- 48 original variables
- Final modeling sample: 30,653 observations
 
## Methods
- Stratified sampling
- KNN imputation
- Feature engineering
- Interaction terms
- Class balancing via downsampling
- 5-fold cross-validation with 3 repeats
- Hyperparameter tuning
 
## Results
- Best model: Balanced Elastic Net
- ROC-AUC: 0.741
- Accuracy: 62.6%
- Recall: 58.3%
- Precision: 52.5%
 
## Key Findings
- Balancing classes improved performance across all model families.
- Elastic Net achieved the strongest overall performance.
- Roadway, weather, traffic, and crash characteristics were informative predictors of injury severity.
 
## Repository Contents
- Final Report
- R Code
- Figures and Visualizations
