library(AFTCoop)

## Useful functions for simulation and graphics 
source("run_manuscript_simulation.R")
source("boxplot_measure.R")

## General settings for running the simulation study 
nsimul<-50
myfolder<-"OUTPUT_SNR"
rate<-40
weak=T # Run the simulation twice. The first with weak=T (weak high dimensional regime); the second with weak=F (strong high dimensional regime)  
lam_min<-F
snr = 0.8
myfolder<-paste(myfolder,snr,sep="_")

## Running the simulation under model weibull
mymodel<-"weibull"

# Case 1:
tu<-6
tz<-6

run_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,folder=myfolder)

# Case 2:
tu<-6
tz<-4
run_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,folder=myfolder)

# Case 3:
tu<-6
tz<-2
run_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,folder=myfolder)

# Case 4:
tu<-6
tz<-0
run_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,folder=myfolder)

## Running the simulation under model lognormal

mymodel<-"lognormal"

# Case 1:
tu<-6
tz<-6

run_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,folder=myfolder)

# Case 2:
tu<-6
tz<-4
run_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,folder=myfolder)

# Case 3:
tu<-6
tz<-2
run_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,folder=myfolder)

# Case 4:
tu<-6
tz<-0
run_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,folder=myfolder)


## Running the simulation under model loglogistic
mymodel<-"loglogistic"

# Case 1:
tu<-6
tz<-6

run_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,folder=myfolder)

# Case 2:
tu<-6
tz<-4
run_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,folder=myfolder)

# Case 3:
tu<-6
tz<-2
run_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,folder=myfolder)

# Case 4:
tu<-6
tz<-0
run_manuscript_simulation(nsimul=nsimul,model=mymodel,tu=tu,tz=tz,weak=weak,rate=rate,snr=snr,folder=myfolder)
