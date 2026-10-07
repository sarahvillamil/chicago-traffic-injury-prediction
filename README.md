## Repo Organization 
### Sub-directories 
-[data/](data): contains all data for this project.
-[recipes/](data): contains all recipes for this project.
-[results/](results): contains all results for this project
-[splits/](plot): contains all splits and folds.

### R Scripts
-   '01_EDA.r': EDA of data.
-   '02_Initial_Set_Up.r': Initial set up: splitting and folding.
-   '03_Recipes.r': Recipes code and set up.
-   '04a_baseline_fit.r': Null fit.
-   '04b_multinom_reg_fit.r': Multinomial regression fits.
-   '04c_elastic_fit.r': Elastic net fits.
-   '04d_knn_fit.r': Nearest neighbor fits.
-   '04e_rf_fit.r': Random forest fits.
-   '04f_bt_fit.r': Boosted tree fits.
-   '05_model_comparison.r': Model comparison and analysis.
-   '06_final_model_train.r': Final model trained and set workflow.
-   '07_final_model_analysis.r': Final model analysis.

### Reports
-   'Villamil_Sarah_final_report.qmd': file for creating final report
-   'Villamil_Sarah_final_report.html': rendered html for final report
-   'Villamil_Sarah_executive_summary.qmd': file for creating executive summary
-   'Villamil_Sarah_executive_summary.html': rendered html for executive summary

# Predicting Injury Severity in Chicago Traffic Crashes
## Overview
In this project, I developed machine learning models to predict injury severity in Chicago traffic crashes using roadway, environmental, and crash-related characteristics.
Using publicly available crash records from the Chicago Data Portal, I built a multiclass classification framework to predict whether a traffic crash would result in:
- No injuries
- One injury
- Two or more injuries
The objective was to identify conditions associated with more severe crashes and develop predictive models that could support roadway safety analysis and policy decisions.
---
## Dataset
### Source
Chicago Traffic Crashes Dataset (Chicago Data Portal) 
### Original Data
- 1,024,029 crash records
- 48 variables
- Data collected between 2015 and 2026
### Final Modeling Dataset
After cleaning, feature engineering, and sampling:
- 30,653 observations
- 16 predictor variables
- Multiclass outcome variable with three injury categories 
---
## Research Question
Can crash characteristics, roadway conditions, weather, and traffic attributes be used to accurately predict injury severity in traffic accidents?
## Features
The final model utilized variables including:
- Day of week
- Hour of crash
- Month
- Street direction
- Roadway surface condition
- Traffic control device
- Traffic control condition
- Number of lanes
- Speed limit
- Weather conditions
- Lighting conditions
- Crash type
- Trafficway type
- Property damage
- Street characteristics
---
## Data Preparation & Feature Engineering
To prepare the data for modeling, I:
- Performed stratified sampling to address dataset scale
- Created balanced and imbalanced modeling datasets
- Applied KNN imputation for missing lane-count values
- Encoded categorical variables
- Created interaction terms between:
- Property damage × crash hour
- Property damage × posted speed limit
- Normalized numerical variables when appropriate
- Applied downsampling to address class imbalance 
---
## Modeling Approach
I compared six model families:
- Null Model
- Multinomial Regression
- Elastic Net
- K-Nearest Neighbors (KNN)
- Random Forest
- Boosted Trees (XGBoost)
Model development included:
- 80/20 Train-Test Split
- Stratified sampling
- 5-Fold Cross Validation
- 3 Repeats
- Hyperparameter tuning
- ROC-AUC optimization
---
## Best Model
### Balanced Elastic Net
The strongest-performing model was a balanced Elastic Net classifier.
### Performance
| Metric | Value |
|----------|----------|
| ROC-AUC | 0.741 |
| Accuracy | 0.626 |
| Recall | 0.583 |
| Precision | 0.525 |
| F1 Score | 0.434 |
---
## Key Findings
- Balancing injury classes improved model performance across every model family.
- Elastic Net achieved the highest overall ROC-AUC score.
- Tree-based models consistently performed well and remained competitive with Elastic Net.
- Crash conditions, roadway characteristics, and environmental factors all contributed predictive information regarding injury severity.
---
## Technologies Used
- R
- Tidymodels
- Elastic Net
- Random Forest
- XGBoost
- K-Nearest Neighbors
- Feature Engineering
- Hyperparameter Tuning
- Cross Validation
- Predictive Modeling
---
