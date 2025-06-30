#' Run Manuscript Simulation for AFT Cooperative Model
#'
#' This function runs multiple simulations to evaluate the performance of the AFTCoop package
#' under different data configurations and regularization settings. It generates synthetic data, applies the aft_coop method, and computes model selection
#' metrics such as False Positive Rate (FPR), False Negative Rate (FNR), Number of Selected Variables Rate (NSR),
#' and Concordance Index (C-index), and optionally generates performance boxplots.
#'
#' @param nsimul Integer. Number of simulation runs to perform.
#' @param model Character. The parametric model used for survival regression (e.g., "weibull", "lognormal", or "loglogistic").
#' @param tu Real value grater of equal than zero to model the correlation etween the latent component and the variables in the U matrix. 
#' @param tz Real value grater of equal than zero to model the correlation etween the latent component and the variables in the X matrix. 
#' @param weak Logical. If `TRUE`, use a "weak dimensionality setting" simulation setting with fewer variables and smaller sample size. If `FALSE`, use a "strong dimensionality setting" setting.
#' @param rate Numeric. Rate parameter for the exponential distribution used in generating data.
#' @param lam_min Logical. Whether to use the lambda_min or :lambda_1se as optimal parameter value in cross-validation.
#' @param snr Numeric. Signal-to-noise ratio used during data generation.
#' @param folder Character. Name of the output folder where result files will be stored.
#' @param iplot_box Logical. Whether to generate and display boxplots of performance metrics at the end of the simulation.
#' @param iplot_CV Logical. Whether to plot cross-validation performance during model training.
#'
#' @return The function does not return a value but writes performance metrics (`C-index`, `FPR`, `FNR`, `NSR`) to text files
#' in the specified `folder`, and optionally displays summary tables and boxplots of performance.
#'
#' @details
#' This function performs repeated simulations using the `generate_data()` and `aft_coop()` functions from the AFTCoop R Package. 
#' It evaluates the performance of models trained using different combinations of input features (`U`, `Z`, or both with cooperative regularization).
#' The function uses parallel computing for efficient cross-validation.
#'
#' @examples
#' \dontrun{
#' run_manuscript_simulation(nsimul = 50, model = "weibull", tu = 6, tz = 6,
#'                           weak = TRUE, rate = 40, lam_min = FALSE,
#'                           snr = 0.8, folder = "OUTPUT", iplot_box = TRUE)
#' }
#'
#' @import survival
#' @import Hmisc
#' @import flexsurv
#' @import cvTools
#' @import stargazer
#' @import tidyverse
#' @import hrbrthemes
#' @import ggpubr
#' @import gridExtra
#' @import AFTCoop

run_manuscript_simulation<-function(nsimul,model,tu,tz,weak=T,rate=40,lam_min =F,snr = snr,folder="OUTPUT",iplot_box=T,iplot_CV=F){
 
  myseed=123
  set.seed(myseed)
  library(survival)
  library(Hmisc)
  library(flexsurv)
  library(cvTools)
  library(stargazer)
  library(tidyverse)
  library(hrbrthemes)
  library(ggpubr)
  library(gridExtra)
  library(AFTCoop)
  
  Start_time <- Sys.time()
  
  dir_out<-paste0(getwd(),"/",folder,"/")
  if (!dir.exists(dir_out)) {
    dir.create(dir_out)
  }
  
  parallel=TRUE
  ncore_max_cv=5
  ncore_max_rho=4

  if(weak==T){
    # size of complete dataset
    n<-200
    # number of variables
    pu<-150
    pz<-150
    rl<-40
    rl_pos <-20
    ntrain<-150
    ntest<-50
  }
  if(weak==F){
    # size of complete dataset
    n<-250
    # number of variables
    pu<-500
    pz<-500
    rl<-40
    rl_pos <-20
    ntrain<-200
    ntest<-50
  }
  
  # the noise on log(times) is sigma_true*noise
  sigma_true <- 0.5
  
  # parameters for the CV
  nfolds <- 5     # number of folds
  
  rho_values<-c(1,0.25,0.5,0.75)
  n_rho_values<-2+length(rho_values)
  
  FPR <- matrix(0,nsimul,n_rho_values) # False Positive Rate
  FNR <- matrix(0,nsimul,n_rho_values) # False Negative Rate
  NSR <- matrix(0,nsimul,n_rho_values) # Number of Selected Rate
  C.index <- matrix(0,nsimul,n_rho_values) # C index
  
  for(isimul in c(1:nsimul)){
    set.seed(myseed*isimul)
    print("---------------------------------------------")
    print("---------------------------------------------")
    print(paste0("Simulation ", isimul))
    
    data<-generate_data(model,n,pu,pz,tu,tz,rate,sigma_true,snr = snr)
    
    Y<-data$Y
    times_c<-data$times_c
    delta<-data$delta
    L<-data$L
    beta_L<-data$beta_L
    U<-data$U
    Z<-data$Z
    
    # Split simulated data into training and test
    times_c_train<-times_c[1:ntrain]
    times_c_test<-times_c[(ntrain+1):n]
    Y_train<-Y[1:ntrain]
    Y_test<-Y[(ntrain+1):n]
    delta_train<-delta[1:ntrain]
    delta_test<-delta[(ntrain+1):n]
    #for performance metrics
    Utrain<-U[1:ntrain,]
    Utest<-U[(ntrain+1):n,]
    Ztrain<-Z[1:ntrain,]
    Ztest<-Z[(ntrain+1):n,]
    
    # sigma estimation using survreg {survival}
    fit_survreg <- survreg(Surv(times_c_train, delta_train)~1, dist=model,scale=0)
    sigma.est <- exp(fit_survreg$icoef[2])
    print(paste("est sigma only intercept", sigma.est))
    
    #######################################################
    case<-"onlyU"
    beta_est<-aft_coop(U=Utrain,Z=Ztrain,Y=Y_train,delta=delta_train,sigma= sigma.est,
                       nfolds=nfolds,model=model,case=case,rho_values=rho_values[1],lam_min=lam_min ,
                       parallel=parallel, ncore_max_rho=ncore_max_rho,ncore_max_cv=ncore_max_cv,seed=myseed*isimul,iplot =  iplot_CV)
    # Performance metrics
    beta_true_pos<-c(rep(1,rl),rep(0,pu-rl))
    
    FNR[isimul,1] <- sum(beta_est[beta_true_pos!=0] == 0)/rl
    FPR[isimul,1] <- sum(beta_est[beta_true_pos==0] != 0)/(pu-rl)
    NSR[isimul,1] <- sum(beta_est != 0)/pu
    print(paste0("Number of variables in the estimated model:",sum(beta_est != 0)))
    predicted<- predict_aft_coop(Utest, Ztest,mU=colMeans(Utrain), beta=beta_est[,1], case = case)
    
    # Rank Correlation for Censored Data
    rank <- Hmisc::rcorr.cens(predicted, Surv(Y_test, delta_test))
    C.index[isimul,1] <- rank[1]
    print((paste0('C-index = ',C.index[isimul,1])))
    print("----------------------------------")
    ############################
    case<-"onlyZ"
    beta_est<-aft_coop(U=Utrain,Z=Ztrain,Y=Y_train,delta=delta_train,sigma= sigma.est,
                       nfolds=nfolds,model=model,case=case,rho_values=rho_values[1],lam_min=lam_min,
                       parallel=parallel, ncore_max_rho=ncore_max_rho,ncore_max_cv=ncore_max_cv,seed=myseed*isimul,iplot =  iplot_CV)
    # Performance metrics
    beta_true_pos<-c(rep(1,rl),rep(0,pz-rl))
    
    FNR[isimul,2] <- sum(beta_est[beta_true_pos!=0] == 0)/rl
    FPR[isimul,2] <- sum(beta_est[beta_true_pos==0] != 0)/(pz-rl)
    NSR[isimul,2] <- sum(beta_est != 0)/pz
    print(paste0("Number of variables in the estimated model:",sum(beta_est != 0)))
    predicted <- predict_aft_coop(Utest, Ztest,mZ=colMeans(Ztrain), beta=beta_est[,1], case = case)
    
    # Rank Correlation for Censored Data
    rank <- Hmisc::rcorr.cens(predicted, Surv(Y_test, delta_test))
    C.index[isimul,2] <- rank[1]
    print((paste0('C-index = ',C.index[isimul,2])))
    print("----------------------------------")
    ############################
    case<-"coop"
    p_active<-2*rl
    p<-pu+pz
    beta_est<-aft_coop(U=Utrain,Z=Ztrain,Y=Y_train,delta=delta_train,sigma= sigma.est,
                       nfolds=nfolds,model=model,case=case,rho_values=rho_values,lam_min=lam_min,
                       parallel=parallel,ncore_max_rho=ncore_max_rho,ncore_max_cv=ncore_max_cv,seed=myseed*isimul,iplot =  iplot_CV)
    
    # Performance metrics
    beta_true_pos<-c(rep(1,rl),rep(0,pu-rl),rep(1,rl),rep(0,pz-rl))
    
    for(i_rho in c(1:(n_rho_values-2))){
      FNR[isimul,2+i_rho] <- sum(beta_est[beta_true_pos!=0,i_rho] == 0)/p_active
      FPR[isimul,2+i_rho] <- sum(beta_est[beta_true_pos==0,i_rho] != 0)/(p-p_active)
      NSR[isimul,2+i_rho] <- sum(beta_est[,i_rho] != 0)/p
      print(paste0("Number of variables in the estimated model:",sum(beta_est[,i_rho] != 0)))
      predicted <- predict_aft_coop(Utest, Ztest,mU=colMeans(Utrain),mZ=colMeans(Ztrain),beta=beta_est[,i_rho], case = case)
      
      # Rank Correlation for Censored Data
      rank <- Hmisc::rcorr.cens(predicted, Surv(Y_test, delta_test))
      C.index[isimul,2+i_rho] <- rank[1]
      print((paste0('C-index = ',C.index[isimul,2+i_rho])))
      print("----------------------------------")
    }
  }
  
  colnames(C.index)<-c("only U","only Z","early fusion",paste0("rho=",rho_values[2:(n_rho_values-2)]))
  file_out=paste0(dir_out,"Cindex_nsimul_",nsimul,"_model_",model,"_weak_",weak,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
  write.table(C.index, file = file_out, sep = "\t", row.names = F, col.names = T)
  
  colnames(FPR)<-c("only U","only Z","early fusion",paste0("rho=",rho_values[2:(n_rho_values-2)]))
  file_out=paste0(dir_out,"FPR_nsimul_",nsimul,"_model_",model,"_weak_",weak,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
  write.table(FPR, file = file_out, sep = "\t", row.names = F, col.names = T)
  
  colnames(FNR)<-c("only U","only Z","early fusion",paste0("rho=",rho_values[2:(n_rho_values-2)]))
  file_out=paste0(dir_out,"FNR_nsimul_",nsimul,"_model_",model,"_weak_",weak,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
  write.table(FNR, file = file_out, sep = "\t", row.names = F, col.names = T)
  
  colnames(NSR)<-c("only U","only Z","early fusion",paste0("rho=",rho_values[2:(n_rho_values-2)]))
  file_out=paste0(dir_out,"NSR_nsimul_",nsimul,"_model_",model,"_weak_",weak,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
  write.table(NSR, file = file_out, sep = "\t", row.names = F, col.names = T)
  
  End_time <- Sys.time()
  
  print(paste0("Running time: ",End_time-Start_time)) 
  
  if (iplot_box){
   # rho_values <- c(0,0.25,0.5,0.75,1)
  #  lrho_values<-length(rho_values)
    
    dir_inpout<-paste0(getwd(),"/",folder,"/")
    
    file_in <- paste0(dir_inpout,"Cindex_nsimul_",nsimul,"_model_",model,"_weak_",weak,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
    Cindex <- read.table(file = file_in, sep = "\t",header = TRUE,check.names=FALSE)
    
    file_in=paste0(dir_inpout,"FPR_nsimul_",nsimul,"_model_",model,"_weak_",weak,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
    FPR=read.table(file = file_in, sep = "\t",header = TRUE,check.names=FALSE)
    
    file_in=paste0(dir_inpout,"FNR_nsimul_",nsimul,"_model_",model,"_weak_",weak,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
    FNR=read.table(file = file_in, sep = "\t",header = TRUE,check.names=FALSE)
    
    file_in <- paste0(dir_inpout,"NSR_nsimul_",nsimul,"_model_",model,"_weak_",weak,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
    NSR <- read.table(file = file_in, sep = "\t",header = TRUE,check.names=FALSE)
    
    tabF <- rbind(apply(Cindex,2,mean),apply(FPR,2,mean),apply(FNR,2,mean),apply(NSR,2,mean))
    tabF<-cbind(c("C-index","FPR","FNR","NSR"),tabF)
    
    colnames(tabF)[1]<-"Error/Method"
    print(tabF)
    
    stargazer(tabF,summary=FALSE)
    file_out=paste0(dir_inpout,"Err_nsimul",nsimul,"_model_",model,"_weak_",weak,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
    write.table(tabF, file = file_out, sep = "\t", row.names = F, col.names = T)
    
 
    bxp1 <- boxplot_measure(nsimul,Cindex,"Cindex")
    bxp2 <- boxplot_measure(nsimul,FPR,"FPR")
    bxp3 <- boxplot_measure(nsimul,FNR,"FNR")
    bxp4 <- boxplot_measure(nsimul,NSR,"NSR")
    
    run_manuscript_simulation<-function(nsimul,model,tu,tz,weak=T,rate=40,lam_min =F,snr = snr,folder="OUTPUT",iplot_box=T,iplot_CV=F){
 
  myseed=123
  set.seed(myseed)
  library(survival)
  library(Hmisc)
  library(flexsurv)
  library(cvTools)
  library(stargazer)
  library(tidyverse)
  library(hrbrthemes)
  library(ggpubr)
  library(gridExtra)
  library(AFTCoop)
  
  Start_time <- Sys.time()
  
  dir_out<-paste0(getwd(),"/",folder,"/")
  if (!dir.exists(dir_out)) {
    dir.create(dir_out)
  }
  
  parallel=TRUE
  ncore_max_cv=5
  ncore_max_rho=4

  if(weak==T){
    # size of complete dataset
    n<-200
    # number of variables
    pu<-150
    pz<-150
    rl<-40
    rl_pos <-20
    ntrain<-150
    ntest<-50
  }
  if(weak==F){
    # size of complete dataset
    n<-250
    # number of variables
    pu<-500
    pz<-500
    rl<-40
    rl_pos <-20
    ntrain<-200
    ntest<-50
  }
  
  # the noise on log(times) is sigma_true*noise
  sigma_true <- 0.5
  
  # parameters for the CV
  nfolds <- 5     # number of folds
  
  rho_values<-c(1,0.25,0.5,0.75)
  n_rho_values<-2+length(rho_values)
  
  FPR <- matrix(0,nsimul,n_rho_values) # False Positive Rate
  FNR <- matrix(0,nsimul,n_rho_values) # False Negative Rate
  NSR <- matrix(0,nsimul,n_rho_values) # Number of Selected Rate
  C.index <- matrix(0,nsimul,n_rho_values) # C index
  
  for(isimul in c(1:nsimul)){
    set.seed(myseed*isimul)
    print("---------------------------------------------")
    print("---------------------------------------------")
    print(paste0("Simulation ", isimul))
    
    data<-generate_data(model,n,pu,pz,tu,tz,rate,sigma_true,snr = snr)
    
    Y<-data$Y
    times_c<-data$times_c
    delta<-data$delta
    L<-data$L
    beta_L<-data$beta_L
    U<-data$U
    Z<-data$Z
    
    # Split simulated data into training and test
    times_c_train<-times_c[1:ntrain]
    times_c_test<-times_c[(ntrain+1):n]
    Y_train<-Y[1:ntrain]
    Y_test<-Y[(ntrain+1):n]
    delta_train<-delta[1:ntrain]
    delta_test<-delta[(ntrain+1):n]
    #for performance metrics
    Utrain<-U[1:ntrain,]
    Utest<-U[(ntrain+1):n,]
    Ztrain<-Z[1:ntrain,]
    Ztest<-Z[(ntrain+1):n,]
    
    # sigma estimation using survreg {survival}
    fit_survreg <- survreg(Surv(times_c_train, delta_train)~1, dist=model,scale=0)
    sigma.est <- exp(fit_survreg$icoef[2])
    print(paste("est sigma only intercept", sigma.est))
    
    #######################################################
    case<-"onlyU"
    beta_est<-aft_coop(U=Utrain,Z=Ztrain,Y=Y_train,delta=delta_train,sigma= sigma.est,
                       nfolds=nfolds,model=model,case=case,rho_values=rho_values[1],lam_min=lam_min ,
                       parallel=parallel, ncore_max_rho=ncore_max_rho,ncore_max_cv=ncore_max_cv,seed=myseed*isimul,iplot =  iplot_CV)
    # Performance metrics
    beta_true_pos<-c(rep(1,rl),rep(0,pu-rl))
    
    FNR[isimul,1] <- sum(beta_est[beta_true_pos!=0] == 0)/rl
    FPR[isimul,1] <- sum(beta_est[beta_true_pos==0] != 0)/(pu-rl)
    NSR[isimul,1] <- sum(beta_est != 0)/pu
    print(paste0("Number of variables in the estimated model:",sum(beta_est != 0)))
    predicted<- predict_aft_coop(Utest, Ztest,mU=colMeans(Utrain), beta=beta_est[,1], case = case)
    
    # Rank Correlation for Censored Data
    rank <- Hmisc::rcorr.cens(predicted, Surv(Y_test, delta_test))
    C.index[isimul,1] <- rank[1]
    print((paste0('C-index = ',C.index[isimul,1])))
    print("----------------------------------")
    ############################
    case<-"onlyZ"
    beta_est<-aft_coop(U=Utrain,Z=Ztrain,Y=Y_train,delta=delta_train,sigma= sigma.est,
                       nfolds=nfolds,model=model,case=case,rho_values=rho_values[1],lam_min=lam_min,
                       parallel=parallel, ncore_max_rho=ncore_max_rho,ncore_max_cv=ncore_max_cv,seed=myseed*isimul,iplot =  iplot_CV)
    # Performance metrics
    beta_true_pos<-c(rep(1,rl),rep(0,pz-rl))
    
    FNR[isimul,2] <- sum(beta_est[beta_true_pos!=0] == 0)/rl
    FPR[isimul,2] <- sum(beta_est[beta_true_pos==0] != 0)/(pz-rl)
    NSR[isimul,2] <- sum(beta_est != 0)/pz
    print(paste0("Number of variables in the estimated model:",sum(beta_est != 0)))
    predicted <- predict_aft_coop(Utest, Ztest,mZ=colMeans(Ztrain), beta=beta_est[,1], case = case)
    
    # Rank Correlation for Censored Data
    rank <- Hmisc::rcorr.cens(predicted, Surv(Y_test, delta_test))
    C.index[isimul,2] <- rank[1]
    print((paste0('C-index = ',C.index[isimul,2])))
    print("----------------------------------")
    ############################
    case<-"coop"
    p_active<-2*rl
    p<-pu+pz
    beta_est<-aft_coop(U=Utrain,Z=Ztrain,Y=Y_train,delta=delta_train,sigma= sigma.est,
                       nfolds=nfolds,model=model,case=case,rho_values=rho_values,lam_min=lam_min,
                       parallel=parallel,ncore_max_rho=ncore_max_rho,ncore_max_cv=ncore_max_cv,seed=myseed*isimul,iplot =  iplot_CV)
    
    # Performance metrics
    beta_true_pos<-c(rep(1,rl),rep(0,pu-rl),rep(1,rl),rep(0,pz-rl))
    
    for(i_rho in c(1:(n_rho_values-2))){
      FNR[isimul,2+i_rho] <- sum(beta_est[beta_true_pos!=0,i_rho] == 0)/p_active
      FPR[isimul,2+i_rho] <- sum(beta_est[beta_true_pos==0,i_rho] != 0)/(p-p_active)
      NSR[isimul,2+i_rho] <- sum(beta_est[,i_rho] != 0)/p
      print(paste0("Number of variables in the estimated model:",sum(beta_est[,i_rho] != 0)))
      predicted <- predict_aft_coop(Utest, Ztest,mU=colMeans(Utrain),mZ=colMeans(Ztrain),beta=beta_est[,i_rho], case = case)
      
      # Rank Correlation for Censored Data
      rank <- Hmisc::rcorr.cens(predicted, Surv(Y_test, delta_test))
      C.index[isimul,2+i_rho] <- rank[1]
      print((paste0('C-index = ',C.index[isimul,2+i_rho])))
      print("----------------------------------")
    }
  }
  
  colnames(C.index)<-c("only U","only Z","early fusion",paste0("rho=",rho_values[2:(n_rho_values-2)]))
  file_out=paste0(dir_out,"Cindex_nsimul_",nsimul,"_model_",model,"_weak_",weak,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
  write.table(C.index, file = file_out, sep = "\t", row.names = F, col.names = T)
  
  colnames(FPR)<-c("only U","only Z","early fusion",paste0("rho=",rho_values[2:(n_rho_values-2)]))
  file_out=paste0(dir_out,"FPR_nsimul_",nsimul,"_model_",model,"_weak_",weak,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
  write.table(FPR, file = file_out, sep = "\t", row.names = F, col.names = T)
  
  colnames(FNR)<-c("only U","only Z","early fusion",paste0("rho=",rho_values[2:(n_rho_values-2)]))
  file_out=paste0(dir_out,"FNR_nsimul_",nsimul,"_model_",model,"_weak_",weak,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
  write.table(FNR, file = file_out, sep = "\t", row.names = F, col.names = T)
  
  colnames(NSR)<-c("only U","only Z","early fusion",paste0("rho=",rho_values[2:(n_rho_values-2)]))
  file_out=paste0(dir_out,"NSR_nsimul_",nsimul,"_model_",model,"_weak_",weak,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
  write.table(NSR, file = file_out, sep = "\t", row.names = F, col.names = T)
  
  End_time <- Sys.time()
  
  print(paste0("Running time: ",End_time-Start_time)) 
  
  if (iplot_box){
   # rho_values <- c(0,0.25,0.5,0.75,1)
  #  lrho_values<-length(rho_values)
    
    dir_inpout<-paste0(getwd(),"/",folder,"/")
    
    file_in <- paste0(dir_inpout,"Cindex_nsimul_",nsimul,"_model_",model,"_weak_",weak,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
    Cindex <- read.table(file = file_in, sep = "\t",header = TRUE,check.names=FALSE)
    
    file_in=paste0(dir_inpout,"FPR_nsimul_",nsimul,"_model_",model,"_weak_",weak,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
    FPR=read.table(file = file_in, sep = "\t",header = TRUE,check.names=FALSE)
    
    file_in=paste0(dir_inpout,"FNR_nsimul_",nsimul,"_model_",model,"_weak_",weak,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
    FNR=read.table(file = file_in, sep = "\t",header = TRUE,check.names=FALSE)
    
    file_in <- paste0(dir_inpout,"NSR_nsimul_",nsimul,"_model_",model,"_weak_",weak,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
    NSR <- read.table(file = file_in, sep = "\t",header = TRUE,check.names=FALSE)
    
    tabF <- rbind(apply(Cindex,2,mean),apply(FPR,2,mean),apply(FNR,2,mean),apply(NSR,2,mean))
    tabF<-cbind(c("C-index","FPR","FNR","NSR"),tabF)
    
    colnames(tabF)[1]<-"Error/Method"
    print(tabF)
    
    stargazer(tabF,summary=FALSE)
    file_out=paste0(dir_inpout,"Err_nsimul",nsimul,"_model_",model,"_weak_",weak,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
    write.table(tabF, file = file_out, sep = "\t", row.names = F, col.names = T)
    
 
    bxp1 <- boxplot_measure(nsimul,Cindex,"Cindex")
    bxp2 <- boxplot_measure(nsimul,FPR,"FPR")
    bxp3 <- boxplot_measure(nsimul,FNR,"FNR")
    bxp4 <- boxplot_measure(nsimul,NSR,"NSR")
    
    file_out <- paste0(dir_inpout, "Boxplot_nsimul_", nsimul, "_model_", model,
                       "_weak_", weak, "_tu_", tu, "_tz_", tz, "_rate_", rate,
                       "_lam_min_", lam_min, "_SNR_", snr, ".pdf")
    
    combined_plot <- grid.arrange(bxp1, bxp2, bxp3, bxp4, ncol = 4, nrow = 1)
    
    ggsave(file_out, plot = combined_plot, width = 12, height = 4)
    
  }
 
}
    
    file_out <- paste0(dir_inpout, "Boxplot_nsimul_", nsimul, "_model_", model,
                       "_weak_", weak, "_tu_", tu, "_tz_", tz, "_rate_", rate,
                       "_lam_min_", lam_min, "_SNR_", snr, ".png")
    
    combined_plot <- grid.arrange(bxp1, bxp2, bxp3, bxp4, ncol = 4, nrow = 1)
    
    ggsave(file_out, plot = combined_plot,width = 12, height = 4, dpi = 300,device="png", bg = "white")   
    
  }
 
}