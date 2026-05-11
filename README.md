---
title: "AFTCoop simulation study"
output: rmarkdown::github_document
---

# AFTCoop simulation study

These scripts enable the execution of the simulation study described in the manuscript by C. Angelini, D. De Canditiis, I. De Feis, and A. Iuliano. *Cooperative AFT models for multi-omics data integration*. Submitted (2025).
 
Such simulations aim to assess the performance of the R package **AFTCoop** in fitting cooperative AFT survival regression models with two omics views.

It is divided into two parts: "Main simulation" and "Additional simulation".

- The Main simulation will reproduce the results shown in Subsection 5.3 (Table 2, Fig. 1, and Fig. 2 for the Weibull model) and in the Supplementary information file (Section S4, Tables S1-S1, and Figures S1-S4 for the log-normal and log-logistic models).

- The Additional simulation will reproduce the results shown in Subsection 5.4. (i.e., Fig. 3).

## Description

To execute the simulations:

-  Install the R package **AFTCoop** from GitHub (results refer to version 0.2.4).
-  Download the R scripts in this repository.
-  (optional) Test the proper installation of the **AFTCoop** Package by running the test example *Test_function_1.R.*

**To run the Main simulation**

-  Open the *Main_Simulation_Direct_algorithm.R* in RStudio and set the working directory to the source file location.
-  Run the *Main_Simulation_Direct_algorithm.R* with the parameter in the simulation configuration.
-  Simulation output will be saved in the folder **OUTPUT_SNR_XX**, where XX corresponds to the SNR signal provided in the simulation settings. 
   Note: To reproduce the manuscript simulation, the SNR must remain set to 0.8, as in the *Main_Simulation_Direct_algorithm.R*. Therefore, the output folder is **OUTPUT_SNR_0.8**.
-  The simulation should be run twice: First setting *weak<-T* (for the weak dimensionality setting), then setting *weak<-F* (for the strong dimensionality setting). 

**To run the Additional simulation**

-  Open the *Additional_Simulation_Direct_algorithm.R* in RStudio and set the working directory to the source file location.
-  Run the *Additional_Simulation_Direct_algorithm.R* with the parameter in the simulation configuration.
-  Simulation output will be saved in the folder **Additional_OUTPUT** . 

## 🧪 AFTCoop Installation

For now, install the latest version of **AFTCoop** directly from GitHub:

```r
install.packages("devtools")
devtools::install_github("angeclau/AFTCoop")
```

For more information see: \url{https://github.com/angeclau/AFTCoop}.

## 🧪 Running AFTCoop simulation study

For the main simulation, the R function *Main_Simulation_Direct_algorithm.R* serves as a wrapper for the main simulation study, which consists of several scenarios.
The most relevant function is *run_main_manuscript_simulation.R*, which calls the $generate\_data()$ and $aft\_coop()$ functions from the **AFTCoop** R Package and performs the analysis for a given scenario.
The pre-computed output is saved in the **OUTPUT_SNR_0.8** folder and consists of several boxplots (in PDF format) and several tables (in txt format).
For example, *Table_Err_nsimul50_model_weibull_weak_TRUE_tu_6_tz_6_rate_40_lam_min_FALSE_SNR_0.8.txt* corresponds to the 50 simulations for the Weibull model, in the weak dimensionality scenario, with  $t_U=t_Z=6$.
The *Boxplot_nsimul_50_model_weibull_weak_TRUE_tu_6_tz_6_rate_40_lam_min_FALSE_SNR_0.8.pdf* is the corresponding boxplot.
See the documentation of *run_main_manuscript_simulation.R* for further information.

For the additional simulation, the R function *Additional_Simulation_Direct_algorithm.R* is a wrapper for the additional simulation study.
The most relevant function is *run_additional_manuscript_simulation.R*, which calls the generate_data() and aft_coop() functions from the **AFTCoop** R Package.
The pre-computed output is saved in the **Additional_OUTPUT** folder and consists of several boxplots (in PDF format) and several tables (in txt format).
For example, the *Figure_additional_50_model_weibull_tu_6_tz_6_rate_40_lam_min_FALSE_SNR_0.8.pdf* refers to the boxplot of 50 additional simulations for the Weibull model with $t_U=t_Z=6$.
See the documentation of *run_additional_manuscript_simulation.R* for further information.


## 📚 Citation
please cite:
1. C. Angelini, D. De Canditiis, I. De Feis, A. Iuliano. *Cooperative AFT models for multi-omics data integration*, Submitted (2025).

### 🏛 Funding
This work is supported by the PRIN 2022 PNRR P2022BLN38 project, *Computational approaches for the integration of multi-omics data* funded by European Union - Next Generation EU, CUP **B53D23027810001**.
