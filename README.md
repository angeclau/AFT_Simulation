---
title: "AFTCoop illustrative simulation studies"
output: rmarkdown::github_document
---


# AFTCoop simulation study

These scripts enable the execution of the simulation study described in
the manuscript by C. Angelini, D. De Canditiis, I. De Feis, and A.
Iuliano. *Cooperative AFT models for multi-omics data integration*.
Submitted (2025).

The simulations aim to assess the performance of the R package
**AFTCoop** in fitting cooperative AFT survival regression models with
two omics views.

It is divided into two parts: **Main simulation** and **Additional simulation**.

- The **Main simulation** will reproduce the results shown in Subsection 5.3
  (Table 2, Fig. 1, and Fig. 2 for the Weibull model) and in the
  Supplementary information file (Section S4, Tables S1-S2, and Figures
  S1-S4 for the log-normal and log-logistic models).

- The **Additional simulation** will reproduce the results shown in
  Subsection 5.4. (i.e., Fig. 3).

## Description

To execute the simulations:

1.  Install the R package **AFTCoop** from GitHub (results refer to
    version 0.2.4).
2.  (optional) Test the proper installation of the **AFTCoop** Package
    by running the test example *Test_function_1.R.*.
3.  Download the R scripts in this repository.
4.  Install all required packages (see below section **Other
    dependencies**)
5.  (optional) Test proper installation of all additional dependencies
    running the test *Test_packages.R*
6.  Run the **Main Simulation** (as described below)
7.  Run the **Additional Simulation** (as described below).

**To run the Main simulation**

- Open the *Main_Simulation_Direct_algorithm.R* in RStudio and set the
  working directory to the source file location.
- Run the *Main_Simulation_Direct_algorithm.R*
- Intermediate simulation output will be saved in the folder
  **OUTPUT_SNR_0.8**.

The main simulation will run twice inside a for loop over the dimesionality settings:

1.  It executes the setting weak\<-T (for the weak dimensionality
    setting),
2.  Then, it executes weak\<-F (for the strong dimensionality setting).

The case *weak\<-T* corresponds to the weak effect of high
dimensionality. The case *weak\<-F* corresponds to the strong effect of
high dimensionality. Partial results for each combination of model and
parameter are saved in the folder **OUTPUT_SNR_0.8**.

At the end of the for loop:

- **Table 2** aggregates intermediate results for model=“weibull”;

- **Tables S1-S2** aggregate intermediate results for model=“lognormal”
  and model=“loglogistic”, respectively.

These tables are saved in the folder
**OUTPUT_SNR_0.8/MainSimulationTables**.

- **Figure 1** and **Figure 2** aggregate results for model=“weibull”;\

- **Figures S1-S4** aggregate results for model=“lognormal” and
  model=“loglogistic”, respectively.

These figures are saved in the folder
**OUTPUT_SNR_0.8/MainSimulationFigures**.

**To run the Additional simulation**

- Open the *Additional_Simulation_Direct_algorithm.R* in RStudio and set
  the working directory to the source file location.
- Run the *Additional_Simulation_Direct_algorithm.R* with the parameter
  in the simulation configuration.
- Intermediate simulation output will be saved in the folder
  **Additional_OUTPUT**.
- At the end of the core part, Figure 3 aggregates intermediate results
  and is saved in **Additional_OUTPUT/SimulationFigure**.

## 🧪 AFTCoop Installation

For now, install the latest version of **AFTCoop** directly from GitHub:

``` r
install.packages("devtools")
devtools::install_github("angeclau/AFTCoop")
```

Recall that for installing a package from GitHub you need the “devtools”
library. For more information about AFTCoop installation, see:
<https://github.com/angeclau/AFTCoop>

## Other dependencies

This simulation workflow requires the following R packages:

``` r
library(devtools)
library(survival) 
library(Hmisc) 
library(flexsurv)
library(cvTools)
library(stargazer) 
library(tidyverse) 
library(hrbrthemes)
library(gridExtra)
library(survAUC)
library(systemfonts) 
library(extrafont)
library(magick)
library(pdftools)
library(sessioninfo)
```

You can install all required packaged using

``` r
install.packages(c("survival", "Hmisc", "flexsurv", "cvTools", "stargazer",
                   "tidyverse", "hrbrthemes", "ggpubr", "gridExtra", "survAUC",
                   "systemfonts", "extrafont", "devtools","magick","pdftools","sessioninfo"))
```

## 🧪 Organization of the AFTCoop simulation study

For the main simulation, the R function
*Main_Simulation_Direct_algorithm.R* serves as a wrapper for the main
simulation study, which consists of several scenarios.

The *Main_Simulation_Direct_algorithm.R* function runs 4 parameter
configurations per each of the 3 models and 2 dimensionality settings.
In particular, the simulation considers: - $t_U=6$ and $t_Z$ can assume
values 6,4,2,0. (parameter configurations) - model can assume values
“weibull”,“lognormal” and “loglogistic” (model configurations) - weak
can assume values TRUE and FALSE (dimensionality scenario
configurations). The entire main simulation has a total of:
$3 \times 4 \times 2 = 24$ simulation scenarios, and 50 independent
realizations in each.

At the end of the main simulation, the manuscript Figures and Tables
aggregate intermediate results.

The most relevant function is *run_main_manuscript_simulation.R*, which
calls the generate_data() and aft_coop() functions from the **AFTCoop**
R Package and performs the analysis for a given scenario (setting
parameters, model, dimensionality settings). The intermediate results
are saved in the **OUTPUT_SNR_0.8** folder and consists of several
boxplots (in PDF format) and several tables (in txt format). For
example,
*Table_Err_nsimul50_model_weibull_weak_TRUE_tu_6_tz_6_rate_40_lam_min_FALSE_SNR_0.8.txt*
corresponds to the 50 simulations for the Weibull model, in the weak
dimensionality scenario, with $t_U=t_Z=6$. The
*Boxplot_nsimul_50_model_weibull_weak_TRUE_tu_6_tz_6_rate_40_lam_min_FALSE_SNR_0.8.pdf*
is the corresponding boxplot.

See the documentation of *run_main_manuscript_simulation.R* for detailed
information.

For the additional simulation, the R function
*Additional_Simulation_Direct_algorithm.R* is a wrapper for the
additional simulation study. The most relevant function is
*run_additional_manuscript_simulation.R*, which calls the
generate_data() and aft_coop() functions from the **AFTCoop** R Package.
The intermediate outputs are saved in the **Additional_OUTPUT** folder
and consist of several boxplots (in PDF format) and several tables (in
txt format). For example, the
*Figure_additional_50_model_weibull_tu_6_tz_6_rate_40_lam_min_FALSE_SNR_0.8.pdf*
refers to the boxplot of 50 additional simulations for the Weibull model
with $t_U=t_Z=6$. At the end of the additional simulations, the
intermediate results are aggregated in Figure 3 of the manuscript.

See the documentation of *run_additional_manuscript_simulation.R* for
detailed information.

## 🧪 Other useful Info about the simulation

The simulation results shown in the manuscript were obtained using R
version 4.5.3 on a MacBook pro Apple M4 Max using only parallelization
over rho values and default settings.

- The execution of **Main_Simulation_Direct_algorithm.R** requires about
  17 hours: Intermediate results are saved in the **OUTPUT_SNR_0.8**
  folder. In particular,
  1.  Each combination of $t_U$ and $t_Z$ for *weak\<-T* requires about
      5-10 minutes. The entire set (4 parameter combinations x 3 models)
      for *weak\<-T* requires about 1.5-2 hours.
  2.  Each combination of $t_U$ and $t_Z$ for *weak\<-F* requires about
      1-1.5 hours The entire set (4 parameter combinations x 3 models)
      requires about 15-16 hours.
- The execution of **Additional_Simulation_Direct_algorithm.R** requires
  about 9 hours. Intermediate results are saved in the
  **Additional_OUTPUT** folder.

## Session Info for the Main Simulation

─ Session info ───────────────────────────────────────────────────────────────────────────────────────────────────────────
 setting  value
 version  R version 4.5.3 (2026-03-11)
 os       macOS 27.0.1
 system   aarch64, darwin20
 ui       RStudio
 language (EN)
 collate  en_US.UTF-8
 ctype    en_US.UTF-8
 tz       Europe/Rome
 date     2026-10-14
 rstudio  2026.09.0+174 Autumn Hawkbit (desktop)
 pandoc   3.10 @ /Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64/ (via rmarkdown)
 quarto   1.10.18 @ /Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto

─ Packages ───────────────────────────────────────────────────────────────────────────────────────────────────────────────
 package      * version    date (UTC) lib source
 abind          1.4-8      2024-09-12 [1] CRAN (R 4.5.0)
 AFTCoop      * 0.2.4      2026-04-28 [1] local (AFTCoop_0.2.4.tar.gz)
 askpass        1.2.1      2024-10-04 [1] CRAN (R 4.5.0)
 backports      1.5.1      2026-04-03 [1] CRAN (R 4.5.2)
 base64enc      0.1-6      2026-02-02 [1] CRAN (R 4.5.2)
 broom          1.0.13     2026-05-14 [1] CRAN (R 4.5.2)
 car            3.1-5      2026-02-03 [1] CRAN (R 4.5.2)
 carData        3.0-6      2026-01-30 [1] CRAN (R 4.5.2)
 checkmate      2.3.4      2026-02-03 [1] CRAN (R 4.5.2)
 cli            3.6.6      2026-04-09 [1] CRAN (R 4.5.2)
 cluster        2.1.8.3    2026-07-30 [1] CRAN (R 4.5.2)
 colorspace     2.1-4      2026-10-08 [1] CRAN (R 4.5.2)
 cvTools      * 0.3.3      2024-03-13 [1] CRAN (R 4.5.0)
 data.table     1.18.6.1   2026-08-24 [1] CRAN (R 4.5.2)
 DEoptimR       1.2-2      2026-09-25 [1] CRAN (R 4.5.2)
 deSolve        1.42       2026-03-20 [1] CRAN (R 4.5.2)
 digest         0.6.39     2025-11-19 [1] CRAN (R 4.5.2)
 dplyr        * 1.2.1      2026-04-03 [1] CRAN (R 4.5.2)
 evaluate       1.0.5      2025-08-27 [1] CRAN (R 4.5.0)
 extrafont      0.20       2025-09-24 [1] CRAN (R 4.5.0)
 extrafontdb    1.1        2025-09-28 [1] CRAN (R 4.5.0)
 farver         2.1.2      2024-05-13 [1] CRAN (R 4.5.0)
 fastmap        1.2.0      2024-05-15 [1] CRAN (R 4.5.0)
 flexsurv     * 2.3.2      2024-08-17 [1] CRAN (R 4.5.0)
 forcats      * 1.0.1      2025-09-25 [1] CRAN (R 4.5.0)
 foreign        0.8-91     2026-01-29 [1] CRAN (R 4.5.3)
 Formula        1.2-6      2026-08-03 [1] CRAN (R 4.5.2)
 generics       0.1.4      2025-05-09 [1] CRAN (R 4.5.0)
 ggplot2      * 4.0.3      2026-04-22 [1] CRAN (R 4.5.2)
 ggpubr       * 1.0.0      2026-07-06 [1] CRAN (R 4.5.2)
 ggsignif       0.6.4      2022-10-13 [1] CRAN (R 4.5.0)
 glue           1.8.1      2026-04-17 [1] CRAN (R 4.5.2)
 gridExtra    * 2.3.1      2026-06-25 [1] CRAN (R 4.5.2)
 gtable         0.3.6      2024-10-25 [1] CRAN (R 4.5.0)
 Hmisc        * 5.3-0      2026-09-06 [1] CRAN (R 4.5.2)
 hms            1.1.4      2025-10-17 [1] CRAN (R 4.5.0)
 hrbrthemes   * 0.9.3      2026-04-20 [1] CRAN (R 4.5.2)
 htmlTable      2.5.0      2026-04-22 [1] CRAN (R 4.5.2)
 htmltools      0.5.9      2025-12-04 [1] CRAN (R 4.5.2)
 htmlwidgets    1.6.4      2023-12-06 [1] CRAN (R 4.5.0)
 knitr          1.52       2026-09-06 [1] CRAN (R 4.5.2)
 labeling       0.4.3      2023-08-29 [1] CRAN (R 4.5.0)
 lattice      * 0.23-1     2026-08-12 [1] CRAN (R 4.5.2)
 lifecycle      1.0.5      2026-01-08 [1] CRAN (R 4.5.2)
 lubridate    * 1.9.5      2026-02-04 [1] CRAN (R 4.5.2)
 magick       * 2.9.1      2026-02-28 [1] CRAN (R 4.5.2)
 magrittr       2.0.5      2026-04-04 [1] CRAN (R 4.5.2)
 Matrix         1.7-6      2026-07-25 [1] CRAN (R 4.5.2)
 mstate         0.3.3      2024-07-11 [1] CRAN (R 4.5.0)
 muhaz          1.2.6.5    2026-07-29 [1] CRAN (R 4.5.2)
 mvtnorm        1.4-2      2026-07-12 [1] CRAN (R 4.5.2)
 nnet           7.3-21     2026-08-03 [1] CRAN (R 4.5.2)
 numDeriv       2016.8-1.1 2019-06-06 [1] CRAN (R 4.5.0)
 otel           0.2.0      2025-08-29 [1] CRAN (R 4.5.0)
 pdftools       3.9.1      2026-09-01 [1] CRAN (R 4.5.2)
 pillar         1.11.1     2025-09-17 [1] CRAN (R 4.5.0)
 pkgconfig      2.0.3      2019-09-22 [1] CRAN (R 4.5.0)
 purrr        * 1.2.2      2026-04-10 [1] CRAN (R 4.5.2)
 qpdf           1.4.1      2025-07-02 [1] CRAN (R 4.5.0)
 quadprog       1.5-8      2019-11-20 [1] CRAN (R 4.5.0)
 R6             2.6.1      2025-02-15 [1] CRAN (R 4.5.0)
 RColorBrewer   1.1-3      2022-04-03 [1] CRAN (R 4.5.0)
 Rcpp           1.1.2      2026-07-05 [1] CRAN (R 4.5.2)
 readr        * 2.2.0      2026-02-19 [1] CRAN (R 4.5.2)
 rlang          1.3.0      2026-07-05 [1] CRAN (R 4.5.2)
 rmarkdown      2.32       2026-09-01 [1] CRAN (R 4.5.2)
 robustbase   * 0.99-7     2026-02-05 [1] CRAN (R 4.5.2)
 rpart          4.1.27     2026-03-27 [1] CRAN (R 4.5.2)
 RSpectra       0.16-2     2024-07-18 [1] CRAN (R 4.5.0)
 rstatix        1.1.0      2026-07-23 [1] CRAN (R 4.5.2)
 rstudioapi     0.19.0     2026-06-11 [1] CRAN (R 4.5.2)
 Rttf2pt1       1.3.14     2025-09-26 [1] CRAN (R 4.5.0)
 S7             0.2.2      2026-04-22 [1] CRAN (R 4.5.2)
 scales         1.4.0      2025-04-24 [1] CRAN (R 4.5.0)
 sessioninfo    1.2.4      2026-06-04 [1] CRAN (R 4.5.2)
 stargazer    * 5.2.3      2022-03-04 [1] CRAN (R 4.5.0)
 statmod        1.5.2      2026-05-17 [1] CRAN (R 4.5.2)
 stringi        1.8.9      2026-08-04 [1] CRAN (R 4.5.2)
 stringr      * 1.6.0      2025-11-04 [1] CRAN (R 4.5.0)
 survAUC      * 1.4-0      2025-09-26 [1] CRAN (R 4.5.0)
 survival     * 3.8-12     2026-09-09 [1] CRAN (R 4.5.2)
 systemfonts    1.3.2      2026-03-05 [1] CRAN (R 4.5.2)
 tibble       * 3.3.1      2026-01-11 [1] CRAN (R 4.5.2)
 tidyr        * 1.3.2      2025-12-19 [1] CRAN (R 4.5.2)
 tidyselect     1.2.1      2024-03-11 [1] CRAN (R 4.5.0)
 tidyverse    * 2.0.0      2023-02-22 [1] CRAN (R 4.5.0)
 timechange     0.4.0      2026-01-29 [1] CRAN (R 4.5.2)
 tzdb           0.5.0      2025-03-15 [1] CRAN (R 4.5.0)
 vctrs          0.7.3      2026-04-11 [1] CRAN (R 4.5.2)
 withr          3.0.3      2026-06-19 [1] CRAN (R 4.5.2)
 xfun           0.61       2026-09-16 [1] CRAN (R 4.5.2)

 [1] /Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/library
 * ── Packages attached to the search path.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────



## Session Info for the Additional Simulation

───────────────────────────────────────────────────────────────────────────────────────────────────────────
 setting  value
 version  R version 4.5.3 (2026-03-11)
 os       macOS 27.0.1
 system   aarch64, darwin20
 ui       RStudio
 language (EN)
 collate  en_US.UTF-8
 ctype    en_US.UTF-8
 tz       Europe/Rome
 date     2026-10-14
 rstudio  2026.09.0+174 Autumn Hawkbit (desktop)
 pandoc   3.10 @ /Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64/ (via rmarkdown)
 quarto   1.10.18 @ /Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto

─ Packages ───────────────────────────────────────────────────────────────────────────────────────────────────────────────
 package      * version    date (UTC) lib source
 abind          1.4-8      2024-09-12 [1] CRAN (R 4.5.0)
 AFTCoop      * 0.2.4      2026-04-28 [1] local (AFTCoop_0.2.4.tar.gz)
 askpass        1.2.1      2024-10-04 [1] CRAN (R 4.5.0)
 backports      1.5.1      2026-04-03 [1] CRAN (R 4.5.2)
 base64enc      0.1-6      2026-02-02 [1] CRAN (R 4.5.2)
 broom          1.0.13     2026-05-14 [1] CRAN (R 4.5.2)
 car            3.1-5      2026-02-03 [1] CRAN (R 4.5.2)
 carData        3.0-6      2026-01-30 [1] CRAN (R 4.5.2)
 checkmate      2.3.4      2026-02-03 [1] CRAN (R 4.5.2)
 cli            3.6.6      2026-04-09 [1] CRAN (R 4.5.2)
 cluster        2.1.8.3    2026-07-30 [1] CRAN (R 4.5.2)
 colorspace     2.1-4      2026-10-08 [1] CRAN (R 4.5.2)
 cowplot        1.2.0      2025-07-07 [1] CRAN (R 4.5.0)
 cvTools      * 0.3.3      2024-03-13 [1] CRAN (R 4.5.0)
 data.table     1.18.6.1   2026-08-24 [1] CRAN (R 4.5.2)
 DEoptimR       1.2-2      2026-09-25 [1] CRAN (R 4.5.2)
 deSolve        1.42       2026-03-20 [1] CRAN (R 4.5.2)
 digest         0.6.39     2025-11-19 [1] CRAN (R 4.5.2)
 dplyr        * 1.2.1      2026-04-03 [1] CRAN (R 4.5.2)
 evaluate       1.0.5      2025-08-27 [1] CRAN (R 4.5.0)
 extrafont      0.20       2025-09-24 [1] CRAN (R 4.5.0)
 extrafontdb    1.1        2025-09-28 [1] CRAN (R 4.5.0)
 farver         2.1.2      2024-05-13 [1] CRAN (R 4.5.0)
 fastmap        1.2.0      2024-05-15 [1] CRAN (R 4.5.0)
 flexsurv     * 2.3.2      2024-08-17 [1] CRAN (R 4.5.0)
 forcats      * 1.0.1      2025-09-25 [1] CRAN (R 4.5.0)
 foreign        0.8-91     2026-01-29 [1] CRAN (R 4.5.3)
 Formula        1.2-6      2026-08-03 [1] CRAN (R 4.5.2)
 generics       0.1.4      2025-05-09 [1] CRAN (R 4.5.0)
 ggplot2      * 4.0.3      2026-04-22 [1] CRAN (R 4.5.2)
 ggpubr       * 1.0.0      2026-07-06 [1] CRAN (R 4.5.2)
 ggsignif       0.6.4      2022-10-13 [1] CRAN (R 4.5.0)
 glue           1.8.1      2026-04-17 [1] CRAN (R 4.5.2)
 gridExtra    * 2.3.1      2026-06-25 [1] CRAN (R 4.5.2)
 gtable         0.3.6      2024-10-25 [1] CRAN (R 4.5.0)
 Hmisc        * 5.3-0      2026-09-06 [1] CRAN (R 4.5.2)
 hms            1.1.4      2025-10-17 [1] CRAN (R 4.5.0)
 hrbrthemes   * 0.9.3      2026-04-20 [1] CRAN (R 4.5.2)
 htmlTable      2.5.0      2026-04-22 [1] CRAN (R 4.5.2)
 htmltools      0.5.9      2025-12-04 [1] CRAN (R 4.5.2)
 htmlwidgets    1.6.4      2023-12-06 [1] CRAN (R 4.5.0)
 knitr          1.52       2026-09-06 [1] CRAN (R 4.5.2)
 labeling       0.4.3      2023-08-29 [1] CRAN (R 4.5.0)
 lattice      * 0.23-1     2026-08-12 [1] CRAN (R 4.5.2)
 lifecycle      1.0.5      2026-01-08 [1] CRAN (R 4.5.2)
 lubridate    * 1.9.5      2026-02-04 [1] CRAN (R 4.5.2)
 magick       * 2.9.1      2026-02-28 [1] CRAN (R 4.5.2)
 magrittr       2.0.5      2026-04-04 [1] CRAN (R 4.5.2)
 Matrix         1.7-6      2026-07-25 [1] CRAN (R 4.5.2)
 mstate         0.3.3      2024-07-11 [1] CRAN (R 4.5.0)
 muhaz          1.2.6.5    2026-07-29 [1] CRAN (R 4.5.2)
 mvtnorm        1.4-2      2026-07-12 [1] CRAN (R 4.5.2)
 nnet           7.3-21     2026-08-03 [1] CRAN (R 4.5.2)
 numDeriv       2016.8-1.1 2019-06-06 [1] CRAN (R 4.5.0)
 otel           0.2.0      2025-08-29 [1] CRAN (R 4.5.0)
 pdftools       3.9.1      2026-09-01 [1] CRAN (R 4.5.2)
 pillar         1.11.1     2025-09-17 [1] CRAN (R 4.5.0)
 pkgconfig      2.0.3      2019-09-22 [1] CRAN (R 4.5.0)
 purrr        * 1.2.2      2026-04-10 [1] CRAN (R 4.5.2)
 qpdf           1.4.1      2025-07-02 [1] CRAN (R 4.5.0)
 quadprog       1.5-8      2019-11-20 [1] CRAN (R 4.5.0)
 R6             2.6.1      2025-02-15 [1] CRAN (R 4.5.0)
 RColorBrewer   1.1-3      2022-04-03 [1] CRAN (R 4.5.0)
 Rcpp           1.1.2      2026-07-05 [1] CRAN (R 4.5.2)
 readr        * 2.2.0      2026-02-19 [1] CRAN (R 4.5.2)
 rlang          1.3.0      2026-07-05 [1] CRAN (R 4.5.2)
 rmarkdown      2.32       2026-09-01 [1] CRAN (R 4.5.2)
 robustbase   * 0.99-7     2026-02-05 [1] CRAN (R 4.5.2)
 rpart          4.1.27     2026-03-27 [1] CRAN (R 4.5.2)
 RSpectra       0.16-2     2024-07-18 [1] CRAN (R 4.5.0)
 rstatix        1.1.0      2026-07-23 [1] CRAN (R 4.5.2)
 rstudioapi     0.19.0     2026-06-11 [1] CRAN (R 4.5.2)
 Rttf2pt1       1.3.14     2025-09-26 [1] CRAN (R 4.5.0)
 S7             0.2.2      2026-04-22 [1] CRAN (R 4.5.2)
 scales         1.4.0      2025-04-24 [1] CRAN (R 4.5.0)
 sessioninfo    1.2.4      2026-06-04 [1] CRAN (R 4.5.2)
 stargazer    * 5.2.3      2022-03-04 [1] CRAN (R 4.5.0)
 statmod        1.5.2      2026-05-17 [1] CRAN (R 4.5.2)
 stringi        1.8.9      2026-08-04 [1] CRAN (R 4.5.2)
 stringr      * 1.6.0      2025-11-04 [1] CRAN (R 4.5.0)
 survAUC      * 1.4-0      2025-09-26 [1] CRAN (R 4.5.0)
 survival     * 3.8-12     2026-09-09 [1] CRAN (R 4.5.2)
 systemfonts    1.3.2      2026-03-05 [1] CRAN (R 4.5.2)
 tibble       * 3.3.1      2026-01-11 [1] CRAN (R 4.5.2)
 tidyr        * 1.3.2      2025-12-19 [1] CRAN (R 4.5.2)
 tidyselect     1.2.1      2024-03-11 [1] CRAN (R 4.5.0)
 tidyverse    * 2.0.0      2023-02-22 [1] CRAN (R 4.5.0)
 timechange     0.4.0      2026-01-29 [1] CRAN (R 4.5.2)
 tzdb           0.5.0      2025-03-15 [1] CRAN (R 4.5.0)
 vctrs          0.7.3      2026-04-11 [1] CRAN (R 4.5.2)
 withr          3.0.3      2026-06-19 [1] CRAN (R 4.5.2)
 xfun           0.61       2026-09-16 [1] CRAN (R 4.5.2)

 [1] /Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/library
 * ── Packages attached to the search path.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────


## 📚 Citation

Please, cite: 1. C. Angelini, D. De Canditiis, I. De Feis, A. Iuliano.
*Cooperative AFT models for multi-omics data integration*, Submitted
(2025).

### 🏛 Funding

This work is supported by the PRIN 2022 PNRR P2022BLN38 project,
*Computational approaches for the integration of multi-omics data*
funded by the European Union - Next Generation EU, CUP
**B53D23027810001**.
