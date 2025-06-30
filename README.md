---
title: "AFTCoop simulation study"
output: rmarkdown::github_document
---

# AFTCoop simulation study

These scripts enable the execution of the simulation study described in the manuscript by C. Angelini, D. De Canditiis, I. De Feis, and A. Iuliano. *Cooperative AFT models for multi-omics data integration* in preparation (2025).
 
Such simulations aim to assess the performance of the R package **AFTCoop** in fitting cooperative AFT survival regression models with two omics views.

## Description

To execute the simulation:

-  Install the R package AFTCoop from GitHub.
-  Download the R scripts in this repository.
-  Open the Main_Simulation_Direct_algorithm.R in RStudio and set the working directory to the source file location.
-  Run the Main_Simulation_Direct_algorithm.R with the parameter in the simulation configuration.
-  Simulation output will be saved in the folder OUTPUT_SNR_XX whwre XX correspond to the SNR signal provided in the simulation settings. 


## 🧪 AFTCoop Installation

For now, install the latest version of **AFTCoop** directly from GitHub:

```r
install.packages("devtools")
devtools::install_github("angeclau/AFTCoop")
```

## 🧪 Running AFTCoop simulation study

The R function Main_Simulation_Direct_algorithm.R is a wrapper to the entire simulation study, consisting of several scenarios.
The most relevant function is run_manuscript_simulation.R that call `generate_data()` and `aft_coop()` functions from the AFTCoop R Package. 


## 📚 Citation
please cite:
1. C. Angelini, D. De Canditiis, I. De Feis, A. Iuliano. *Cooperative AFT models for multi-omics data integration* in preparation (2025)

### 🏛 Funding
This work is supported by the PRIN 2022 PNRR P2022BLN38 project, *Computational approaches for the integration of multi-omics data* funded by European Union - Next Generation EU, CUP **B53D23027810001**.
