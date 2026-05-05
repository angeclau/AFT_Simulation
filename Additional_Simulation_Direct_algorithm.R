# This function runs the additional simulation results for the manuscript, 
# which aim to investigate the effect of pre-screening procedures on performance indexes.
# We generate "nsimul" datasets of dimension nxp, where p >> n. 
# In each dataset, only pl variables are significantly associated with the response (through the latent factor L). 
# Then, we fit the synthetic data using the subset of ps variables for different choices of ps. 
# The ps variables represent the results of an optimal screening procedure that can subset the original variables, 
# enabling a transition from a high-dimensional to a moderate-dimensional setting.

## Note, to produce the plot, you might need to install extrafonts as
# install.packages("extrafont")
# library(extrafont)
#
# font_import(pattern = "Arial", prompt = FALSE)
# loadfonts(device = "pdf")


library(AFTCoop)

## Useful functions for simulation and graphics 
source("run_additional_manuscript_simulation.R")
source("plot_measure.R") ## for generating manuscript figures (line plots)

Start_time_main <- Sys.time()

## General settings for running the additional simulation study 
nsimul <- 50
myfolder <-"Additional_OUTPUT"
rate <- 40
lam_min <- F
snr <- 0.8

## parallel setting. The choice depend on the system where the simulation is running
parallel_rho <- TRUE 
ncore_max_rho <- 4
parallel_cv <- TRUE 
ncore_max_cv <- 5 

# Note on Mac Os with Apple Silicon processor and R 4.5.2 it is better to avoid nested parallelism)
if ( getRversion()== "4.5.2" && R.version$arch =="aarch64"){ 
  print("Removed the nested parallelism") 
  parallel_cv<- FALSE
  ncore_max_cv<- 1
}


## Running the additional simulation under model weibull
mymodel<-"weibull"

# Case 1:
tu<-6
tz<-6

run_additional_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,rate=rate,snr=snr, 
                                     parallel.rho= parallel_rho,ncore_max_rho=ncore_max_rho,
                                     parallel.cv= parallel_cv,ncore_max_cv=ncore_max_cv,
                                     folder=myfolder)


# Case 2:
tu<-6
tz<-4

run_additional_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,rate=rate,snr=snr, 
                                     parallel.rho= parallel_rho,ncore_max_rho=ncore_max_rho,
                                     parallel.cv= parallel_cv,ncore_max_cv=ncore_max_cv,
                                     folder=myfolder, legend.plot=FALSE)

# Case 3:
tu<-6
tz<-2

run_additional_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,rate=rate,snr=snr, 
                                     parallel.rho= parallel_rho,ncore_max_rho=ncore_max_rho,
                                     parallel.cv= parallel_cv,ncore_max_cv=ncore_max_cv,
                                     folder=myfolder,legend.plot=FALSE)

# Case 4:
tu<-6
tz<-0

run_additional_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,rate=rate,snr=snr, 
                                     parallel.rho= parallel_rho,ncore_max_rho=ncore_max_rho,
                                     parallel.cv= parallel_cv,ncore_max_cv=ncore_max_cv,
                                     folder=myfolder,legend.plot=FALSE)

End_time_main <- Sys.time()
total_running_time<-End_time_main-Start_time_main
total_running_time
print(paste0("Simulation Running time: ",total_running_time)) 