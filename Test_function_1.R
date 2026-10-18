# To check proper installation of the AFTCoop package please run the Test_function_1.R 
# The test function will generate simulated data and then it will apply the aft_coop() function
# Note: You can check that the parallel setting works with your system

library(AFTCoop)
## Note the parallel setting might depend on your computer architecture and the size of the data-matrices
parallel.rho = TRUE
parallel.cv = TRUE
ncore_max_rho = 2
ncore_max_cv = 5

set.seed(123)
model="weibull"
data <- generate_data(
  model = model,
    n = 200,
    pu = 150,
    pz = 150,
    tu = 6,
    tz = 6,
    rate = 40,
    sigma_true = 0.5
    )

    Y <- data$Y  # vector of log survival times or censored times
    delta <- data$delta  # vector of censoring indicators
    U <- data$U  # matrix corresponding to the first view
    Z <- data$Z  # matrix corresponding to the second view
    fit_survreg <- survreg(Surv(data$times_c, delta)~1, dist=model,scale=0)
    sigma.est <- exp(fit_survreg$icoef[2])
    rho_values<- c(1,0.25,0.5,0.75) #vector parameteters for rho values
    
# Using aft_coop with two views
    beta_est_coop<-aft_coop(
    U=U,
    Z=Z,
    Y=Y,
    delta=delta,
    sigma=sigma.est,
    nfolds=5,
    model=model,
    case="coop",
    rho_values=  rho_values,
    lam_min=F,
    parallel.rho = parallel.rho,
    parallel.cv = parallel.cv,
    ncore_max_rho = ncore_max_rho,
    ncore_max_cv = ncore_max_cv,
    seed=123)

   ## estimate of beta  (the first pu components refers to the view U; The second pz component to view Z  )
   beta_est_coop

# Using aft_coop with only the first view U
    beta_est_onlyU<-aft_coop(
    U=U,
    Z=Z,
    Y=Y,
    delta=delta,
    sigma=sigma.est,
    nfolds=5,
    model=model,
    case="onlyU",
    rho_values=  1,
    lam_min=F,
    parallel.rho = parallel.rho,
    parallel.cv = parallel.cv,
    ncore_max_rho = ncore_max_rho,
    ncore_max_cv = ncore_max_cv,
    seed=123)

    ## Using aft_coop with only the second view
     beta_est_onlyZ<-aft_coop(
        U=U,
        Z=Z,
        Y=Y,
        delta=delta,
        sigma=sigma.est,
        nfolds=5,
        model=model,
        case="onlyZ",
        rho_values=  1,
        lam_min=F,
        parallel.rho = parallel.rho,
        parallel.cv = parallel.cv,
        ncore_max_rho = ncore_max_rho,
        ncore_max_cv = ncore_max_cv,
        seed=123)

        beta_est_onlyZ