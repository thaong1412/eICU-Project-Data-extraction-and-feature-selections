# eICU Dataset Extraction and Exploratory Analysis

This project involves the extraction, cleaning, and exploratory analysis of the eICU Collaborative Research Database (eICU-CRD). The primary goal is to prepare the dataset for further machine learning (ML) modeling and feature selection.

## Table of Contents

- [Project Overview](#project-overview)
- [Dataset Access](#dataset-access)
- [Data Extraction Process](#data-extraction-process)
- [Data Cleaning](#data-cleaning)
- [Exploratory Analysis](#exploratory-analysis)
- [ML Tasks on Similar Datasets](#ml-tasks-on-similar-datasets)
- [Feature Selection](#feature-selection)
- [References](#references)

## Project Overview

This project is a comprehensive study on the eICU dataset, focusing on data extraction, cleaning, and exploratory data analysis. The final goal is to identify and implement a feature selection method that can be applied to the dataset for further ML modeling.

## Dataset Access

The eICU Collaborative Research Database (eICU-CRD) is a freely available dataset provided by the MIT Laboratory for Computational Physiology. The dataset contains high-granularity data from ICU patients across multiple hospitals.

- **eICU Data:** 
  - [eICU-CRD Website](https://eicu-crd.mit.edu/about/eicu/)
  - [eICU GitHub Repository](https://github.com/mit-lcp/eicu-code)

## Data Extraction Process

The first step in this project was to identify and extract the relevant datasets from the eICU database. To determine which datasets to extract, I referred to the following resource:

- **Excel Sheet Reference:** 
  - [Study Link](https://www.mdpi.com/2075-4426/11/9/934)

Based on the findings in this study, I selected datasets that were most relevant to my exploratory analysis and future ML tasks.

## Data Cleaning

After extracting the datasets, I performed the following data cleaning steps:

- **Handling Missing Values:** 
  - Missing values were identified and handled appropriately, either by imputation or removal depending on the percentage of missing data.
  
- **Data Normalization:** 
  - Continuous variables were normalized to ensure that all features are on a similar scale.
  
- **Outlier Detection:** 
  - Outliers were detected and managed through various statistical methods, ensuring they do not skew the analysis.
  
- **Categorical Variable Encoding:** 
  - Categorical variables were encoded using one-hot encoding or label encoding based on the variable type and model requirements.

## Exploratory Analysis

An exploratory analysis was conducted to better understand the structure, relationships, and distributions within the dataset. This included:

- **Descriptive Statistics:** Summary statistics for continuous and categorical variables.
- **Correlation Analysis:** Identifying relationships between variables.
- **Visualization:** Creating histograms, scatter plots, and correlation heatmaps to visualize data distributions and relationships.

## ML Tasks on Similar Datasets

I researched existing ML tasks performed on similar datasets to establish a baseline understanding of common methodologies. This review provided insights into the types of models typically applied to eICU data, such as:

- **Classification tasks** for predicting patient outcomes.


## Feature Selection

Based on the exploratory analysis and the review of related ML tasks, I decided to implement feature selection to enhance model performance. Two feature selection methods were considered:

- **Boruta:** An all-relevant feature selection method using random forest classifier to identify important features.
- **Linear Discriminant Analysis (LDA):** A method used to find the linear combination of features that best separate different classes.

## References

- **eICU Collaborative Research Database:** [https://eicu-crd.mit.edu/about/eicu/](https://eicu-crd.mit.edu/about/eicu/)
- **Related Study on Dataset Selection:** [https://www.mdpi.com/2075-4426/11/9/934](https://www.mdpi.com/2075-4426/11/9/934)
# eICU-Project-Data-extraction-and-feature-selections
# eICU-Project-Data-extraction-and-feature-selections
# eICU-Project-Data-extraction-and-feature-selections
# eICU-Project-Data-extraction-and-feature-selections
# eICU-Project-Data-extraction-and-feature-selections
# eICU-Project-Data-extraction-and-feature-selections
# eICU-Project-Data-extraction-and-feature-selections
