# This function run the main simulation results for the manuscript

library(AFTCoop)

## Useful functions for simulation and graphics 
source("run_main_manuscript_simulation.R")
source("boxplot_measure.R") ## for generating manuscript figures (boxplots)

Start_time_main <- Sys.time()

## General settings for running the main simulation study 
nsimul<-50
myfolder<-"OUTPUT_SNR"
rate<-40
weak<-F # Run the simulation twice. The first with weak=T (weak high dimensional regime); the second with weak=F (strong high dimensional regime)  
lam_min<-F
snr <- 0.8

## parallel setting. The choice depend on the system where the simulation is running
parallel_rho<-TRUE 
ncore_max_rho<-4
parallel_cv<- TRUE
ncore_max_cv<- 5 

# Note on Mac Os with Apple Silicon processor and R 4.5.2 it is better to avoid nested parallelism)
if ( getRversion()>= "4.5.2" && R.version$arch =="aarch64"){ 
  print("Removed the nested parallelism") 
  parallel_cv<- FALSE
  ncore_max_cv<- 1
  }


## Output folder where tables and figures will be saved
myfolder<-paste(myfolder,snr,sep="_")

## Running the simulation under model weibull
mymodel<-"weibull"

# Case 1:
tu<-6
tz<-6

run_main_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,
                               parallel.rho= parallel_rho,
                               ncore_max_rho=ncore_max_rho,
                               parallel.cv= parallel_cv,
                               ncore_max_cv=ncore_max_cv,
                               folder=myfolder)

# Case 2:
tu<-6
tz<-4
run_main_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,
                               parallel.rho= parallel_rho,
                               ncore_max_rho=ncore_max_rho,
                               parallel.cv= parallel_cv,
                               ncore_max_cv=ncore_max_cv,
                               folder=myfolder)

# Case 3:
tu<-6
tz<-2
run_main_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,
                               parallel.rho= parallel_rho,
                               ncore_max_rho=ncore_max_rho,
                               parallel.cv= parallel_cv,
                               ncore_max_cv=ncore_max_cv,
                               folder=myfolder)

# Case 4:
tu<-6
tz<-0
run_main_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,
                               parallel.rho= parallel_rho,
                               ncore_max_rho=ncore_max_rho,
                               parallel.cv= parallel_cv,
                               ncore_max_cv=ncore_max_cv,
                               folder=myfolder)

## Running the simulation under model lognormal

mymodel<-"lognormal"

# Case 1:
tu<-6
tz<-6

run_main_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,
                               parallel.rho= parallel_rho,
                               ncore_max_rho=ncore_max_rho,
                               parallel.cv= parallel_cv,
                               ncore_max_cv=ncore_max_cv,
                               folder=myfolder)

# Case 2:
tu<-6
tz<-4
run_main_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,
                               parallel.rho= parallel_rho,
                               ncore_max_rho=ncore_max_rho,
                               parallel.cv= parallel_cv,
                               ncore_max_cv=ncore_max_cv,
                               folder=myfolder)

# Case 3:
tu<-6
tz<-2
run_main_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,
                               parallel.rho= parallel_rho,
                               ncore_max_rho=ncore_max_rho,
                               parallel.cv= parallel_cv,
                               ncore_max_cv=ncore_max_cv,
                               folder=myfolder)

# Case 4:
tu<-6
tz<-0
run_main_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,
                               parallel.rho= parallel_rho,
                               ncore_max_rho=ncore_max_rho,
                               parallel.cv= parallel_cv,
                               ncore_max_cv=ncore_max_cv,
                               folder=myfolder)

## Running the simulation under model loglogistic
mymodel<-"loglogistic"

# Case 1:
tu<-6
tz<-6

run_main_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,
                               parallel.rho= parallel_rho,
                               ncore_max_rho=ncore_max_rho,
                               parallel.cv= parallel_cv,
                               ncore_max_cv=ncore_max_cv,
                               folder=myfolder)

# Case 2:
tu<-6
tz<-4
run_main_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,
                               parallel.rho= parallel_rho,
                               ncore_max_rho=ncore_max_rho,
                               parallel.cv= parallel_cv,
                               ncore_max_cv=ncore_max_cv,
                               folder=myfolder)

# Case 3:
tu<-6
tz<-2
run_main_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,
                               parallel.rho= parallel_rho,
                               ncore_max_rho=ncore_max_rho,
                               parallel.cv= parallel_cv,
                               ncore_max_cv=ncore_max_cv,
                               folder=myfolder)

# Case 4:
tu<-6
tz<-0
run_main_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,
                               parallel.rho= parallel_rho,
                               ncore_max_rho=ncore_max_rho,
                               parallel.cv= parallel_cv,
                               ncore_max_cv=ncore_max_cv,
                               folder=myfolder)

End_time_main <- Sys.time()
total_running_time<-End_time_main-Start_time_main
total_running_time
print(paste0("Simulation Running time: ",total_running_time)) 
