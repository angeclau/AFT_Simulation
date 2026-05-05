#' Run the additional manuscript simulation study for AFT cooperative models
#'
#' This function performs a simulation study to evaluate the performance of
#' cooperative Accelerated Failure Time (AFT) models under different
#' integration strategies ("onlyU", "onlyZ", and cooperative/early fusion)
#' when fixing the number of significant variables and increasing the number
#' of screened variables included in the model.
#'
#' A large dataset with two views (U and Z) is first generated with
#' \eqn{p = p_u + p_z} variables. The first \code{rl} variables in each view
#' are truly associated with the survival outcome, while the remaining
#' variables act as noise. The simulation mimics a variable screening step by
#' fitting models using only the first \code{p_s} variables from each view,
#' where \code{p_s} increases across scenarios.
#'
#' The aim of the simulation is to investigate how the number of screened
#' variables affects prediction performance and variable selection, thereby
#' motivating the screening procedure used in the manuscript.
#'
#' @param nsimul Integer. Number of simulation replicates.
#' @param model Character. Distribution for the AFT model (e.g. `"weibull"`,
#' `"lognormal"`). Passed to \code{survival::survreg()} and \code{aft_coop()}.
#' @param tu Numeric. Signal strength parameter for the U view.
#' @param tz Numeric. Signal strength parameter for the Z view.
#' @param rate Numeric. Censoring rate parameter used in data generation.
#' @param lam_min Logical. If TRUE, selects `lambda.min` from cross-validation;
#' otherwise uses the default selection from \code{aft_coop()}.
#' @param snr Numeric. Signal-to-noise ratio used in \code{generate_data()}.
#' @param parallel.rho Logical. Whether to parallelize computation across
#' different values of the cooperation parameter \code{rho} (default=TRUE).
#' @param ncore_max_rho Integer. Maximum number of cores used for
#' parallelization across \code{rho} values (default=4).
#' @param parallel.cv Logical. Whether to parallelize cross-validation (default=TRUE).
#' @param ncore_max_cv Integer. Maximum number of cores used for CV
#' parallelization. (default=5).
#' @param folder Character. Name of the output directory where results and
#' plots are saved. The directory is created if it does not exist.
#' @param iplot Logical. If TRUE, aggregates simulation results, generates
#' summary tables and plots, and saves them to disk.
#' @param iplot_CV Logical (default = FALSE). If TRUE, enables plotting
#' within cross-validation inside \code{aft_coop()}.
#' @param legend.plot Logical (default = TRUE). If TRUE, the legend is shown
#' at the top of the final combined figure.
#' @param xgrid.step Integer controlling the spacing of grid values on the
#' x-axis in the plots (default = 200).
#' @param yrange Numeric vector of length two specifying the y-axis range
#' for the plots (default = c(0,1)).
#'
#' @details
#' The simulation uses the following configuration:
#'
#' \itemize{
#'   \item Total sample size: \code{n = 250}.
#'   \item Training size: \code{ntrain = 200}, test size: \code{ntest = 50}.
#'   \item Number of variables in the full dataset:
#'     \code{pu = 500} (view U) and \code{pz = 500} (view Z).
#'   \item Number of truly active variables per view: \code{rl = 40}.
#'   \item Noise scale parameter in the Weibull model: \code{sigma_true = 0.5}.
#'   \item Five-fold cross-validation for model tuning.
#' }
#'
#' The number of screened variables per view varies as:
#' \code{pu_vec = pz_vec = c(100, 200, 300, 400, 500)}.
#'
#' Three modeling strategies are compared:
#'
#' \itemize{
#'   \item `"onlyU"`: model using only the U view.
#'   \item `"onlyZ"`: model using only the Z view.
#'   \item `"coop"`: cooperative integration of the two views.
#' }
#'
#' Cooperative models are fitted for multiple values of the cooperation
#' parameter \code{rho}: \code{c(1, 0.25, 0.5, 0.75)}.
#'
#' Output files include:
#'
#' \itemize{
#'   \item Simulation-level performance metrics (Harrell's C-index, Uno's C-index,
#'   false positive rate (FPR), false negative rate (FNR), and number of selected rate (NSR)).
#'   \item Aggregated performance tables across simulations.
#'   \item PDF figures summarizing performance as a function of the number
#'   of screened variables.
#' }
#'
#' @return
#' This function does not return a value. Instead, it writes simulation
#' results, summary tables, and plots to disk in the specified \code{folder}.
#'
#' @import survival
#' @import Hmisc
#' @import flexsurv
#' @import cvTools
#' @import stargazer
#' @import tidyverse
#' @import hrbrthemes
#' @importFrom ggpubr ggarrange
#' @import gridExtra
#' @import AFTCoop
#' @import survAUC
#'
#' @seealso \code{\link{aft_coop}}, \code{\link{generate_data}},
#' \code{\link{predict_aft_coop}}
#'
#' @examples
#' \dontrun{
#' run_additional_manuscript_simulation(
#'   nsimul = 10,
#'   model = "weibull",
#'   tu = 6,
#'   tz = 6,
#'   snr = 0.8,
#'   folder = "OUTPUT"
#' )
#' }
#'
#' @export
#' @note Last change: 13/03/2026
#' 
run_additional_manuscript_simulation<-function(nsimul,model,tu,tz,rate=40,
                                         lam_min =F,snr = snr, 
                                         parallel.rho= TRUE,
                                         ncore_max_rho=4,
                                         parallel.cv= TRUE,
                                         ncore_max_cv=5,
                                         folder="OUTPUT", 
                                         iplot=T,iplot_CV=F,
                                         legend.plot=TRUE,
                                         xgrid.step=200,yrange=c(0,1)){


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
  library(survAUC)

   
  Start_time <- Sys.time()
  
  dir_out<-paste0(getwd(),"/",folder,"/")
  if (!dir.exists(dir_out)) {
    dir.create(dir_out)
  }
    # size of complete dataset
    n<-250
  
    # number of variables
    pu<-500  ## number of variables in U for the large dataset
    pz<-500 ## number of variables in Z for the large dataset
    p<- pu+pz
    
    rl<-40
    rl_pos <-20
    ntrain<-200
    ntest<-50
    
    # number of screned variables in each view (it should be subset of pu and pz)
    pu_vec<-c(100,200,300,400,500)
    pz_vec<-c(100,200,300,400,500)
    
    rl<-40 # overall number of rtyly significant variables
    rl_pos <-20
    ntrain<-150
    ntest<-50

  # the noise on log(times) is sigma_true*noise
  sigma_true <- 0.5
  
  # parameters for the CV
  nfolds <- 5     # number of folds
  
  rho_values<-c(1,0.25,0.5,0.75)
  n_rho_values<-2+length(rho_values)
  
  FPR <- array(0,c(nsimul,n_rho_values,length(pu_vec))) # False Positive Rate
  FNR <- array(0,c(nsimul,n_rho_values,length(pu_vec))) # False Negative Rate
  NSR <- array(0,c(nsimul,n_rho_values,length(pu_vec))) # Number of Selected Rate
  C.index <- array(0,c(nsimul,n_rho_values,length(pu_vec))) # C index
  C.index_uno <- array(0,c(nsimul,n_rho_values,length(pu_vec))) # UNO C index
  
  for(isimul in c(1:nsimul)){
    set.seed(myseed*isimul)
    print("---------------------------------------------")
    print(paste0("Simulation ", isimul))
    ## For each simulation we generate the large dataset with n samples and p variables.
    ## then we will select the first ps variables to mimick variable screening.
    data<-generate_data(model,n,pu,pz,tu,tz,rate,sigma_true,snr = snr)

    Y<-data$Y
    times_c<-data$times_c
    delta<-data$delta

    # set up of tau for the evaluation of C-index by Uno
    unotimes <- min(quantile(Y,0.90),max(Y[delta!=0]))
    
  for (ps in 1:length(pu_vec)){
    ## for each values of screened variables we perform the fit
    print("---------------------------------------------")
    print("---------------------------------------------")
    pu_s<-pu_vec[ps]
    print(paste0("Number of screened variables (for each view) in the model p = ",pu_s))
    pz_s<-pz_vec[ps]

    L<-data$L
    beta_L<-data$beta_L
    Us<-data$U[,1:pu_s] ## take Us as the first screened columns of U
   # print(paste0("Screened data matrix U of dimension:", dim(Us)))
    Zs<-data$Z[,1:pz_s] ## take Zs as the first screened columns of Z
  #  print(paste0("Screened data matrix Z of dimension:", dim(Zs)))
    
    # Split simulated data into training and test
    times_c_train<-times_c[1:ntrain]
    times_c_test<-times_c[(ntrain+1):n]
    Y_train<-Y[1:ntrain]
    Y_test<-Y[(ntrain+1):n]
    delta_train<-delta[1:ntrain]
    delta_test<-delta[(ntrain+1):n]
    #for performance metrics
    Utrain<-Us[1:ntrain,]
    Utest<-Us[(ntrain+1):n,]
    Ztrain<-Zs[1:ntrain,]
    Ztest<-Zs[(ntrain+1):n,]
    
    # sigma estimation using survreg {survival}
    fit_survreg <- survreg(Surv(times_c_train, delta_train)~1, dist=model,scale=0)
    sigma.est <- exp(fit_survreg$icoef[2])
   # print(paste("est sigma only intercept", sigma.est))
    
    #######################################################
    case<-"onlyU"
    beta_est<-aft_coop(U=Utrain,Z=Ztrain,Y=Y_train,delta=delta_train,sigma= sigma.est,
                       nfolds=nfolds,model=model,case=case,rho_values=rho_values[1],
                       lam_min=lam_min,
                       parallel.rho = parallel.rho,parallel.cv = parallel.cv, 
                       ncore_max_rho=ncore_max_rho,ncore_max_cv=ncore_max_cv,seed=myseed*isimul,
                       iplot =  iplot_CV)
    
     # Performance metrics
    beta_true_pos<-c(rep(1,rl),rep(0,pu_s-rl))
    
    FNR[isimul,1,ps] <- sum(beta_est[beta_true_pos!=0] == 0)/rl
    FPR[isimul,1,ps] <- sum(beta_est[beta_true_pos==0] != 0)/(pu_s-rl)
    NSR[isimul,1,ps] <- sum(beta_est != 0)/pu_s
    print(paste0("Number of variables in the estimated model: ",sum(beta_est != 0)))
    predicted<- predict_aft_coop(Utest, Ztest,mU=colMeans(Utrain), beta=beta_est[,1], case = case)
    
    # Rank Correlation for Censored Data
    rank <- Hmisc::rcorr.cens(predicted, Surv(Y_test, delta_test))
    C.index[isimul,1,ps] <- rank[1]
    print((paste0('C-index = ',C.index[isimul,1,ps])))
    print("----------------------------------")
    
    ## Uno C-index from survAUC package 
    C.index_uno[isimul,1,ps]<- survAUC::UnoC(Surv(Y_train, delta_train), Surv(Y_test, delta_test), -predicted, time =unotimes)
    print((paste0('UNO C-index = ',C.index_uno[isimul,1,ps])))
    
    ############################
    case<-"onlyZ"
    beta_est<-aft_coop(U=Utrain,Z=Ztrain,Y=Y_train,delta=delta_train,sigma= sigma.est,
                       nfolds=nfolds,model=model,case=case,rho_values=rho_values[1],lam_min=lam_min,
                       parallel.rho = parallel.rho,parallel.cv = parallel.cv,  
                       ncore_max_rho=ncore_max_rho,ncore_max_cv=ncore_max_cv,seed=myseed*isimul,
                       iplot =  iplot_CV)
    # Performance metrics
    beta_true_pos<-c(rep(1,rl),rep(0,pz_s-rl))
    
    FNR[isimul,2,ps] <- sum(beta_est[beta_true_pos!=0] == 0)/rl
    FPR[isimul,2,ps] <- sum(beta_est[beta_true_pos==0] != 0)/(pz_s-rl)
    NSR[isimul,2,ps] <- sum(beta_est != 0)/pz_s
    print(paste0("Number of variables in the estimated model: ",sum(beta_est != 0)))
    predicted <- predict_aft_coop(Utest, Ztest,mZ=colMeans(Ztrain), beta=beta_est[,1], case = case)
    
    # Rank Correlation for Censored Data
    rank <- Hmisc::rcorr.cens(predicted, Surv(Y_test, delta_test))
    C.index[isimul,2,ps] <- rank[1]
    print((paste0('C-index = ',C.index[isimul,2,ps])))
    print("----------------------------------")
    
    ## Uno C-index from survAUC package 
    C.index_uno[isimul,2,ps]<- survAUC::UnoC(Surv(Y_train, delta_train), Surv(Y_test, delta_test), -predicted, time =unotimes)
    print((paste0('UNO C-index = ',C.index_uno[isimul,2,ps])))
    
    ############################
    case<-"coop"
    p_active<-2*rl
    p_s<-pu_s+pz_s
    print(paste0("Current number of variables in the two views: ",p_s))
    
    beta_est<-aft_coop(U=Utrain,Z=Ztrain,Y=Y_train,delta=delta_train,sigma= sigma.est,
                       nfolds=nfolds,model=model,case=case,rho_values=rho_values,lam_min=lam_min,
                       parallel.rho = parallel.rho,parallel.cv = parallel.cv, 
                       ncore_max_rho=ncore_max_rho,ncore_max_cv=ncore_max_cv,seed=myseed*isimul,
                       iplot =  iplot_CV)
    
    # Performance metrics
    beta_true_pos<-c(rep(1,rl),rep(0,pu_s-rl),rep(1,rl),rep(0,pz_s-rl))
    
    for(i_rho in c(1:(n_rho_values-2))){
      FNR[isimul,2+i_rho,ps] <- sum(beta_est[beta_true_pos!=0,i_rho] == 0)/p_active
      FPR[isimul,2+i_rho,ps] <- sum(beta_est[beta_true_pos==0,i_rho] != 0)/(p_s-p_active)
      NSR[isimul,2+i_rho,ps] <- sum(beta_est[,i_rho] != 0)/p_s
      print(paste0("Number of variables in the estimated model: ",sum(beta_est[,i_rho] != 0)))
      predicted <- predict_aft_coop(Utest, Ztest,mU=colMeans(Utrain),mZ=colMeans(Ztrain),beta=beta_est[,i_rho], case = case)
      
      # Rank Correlation for Censored Data
      rank <- Hmisc::rcorr.cens(predicted, Surv(Y_test, delta_test))
      C.index[isimul,2+i_rho,ps] <- rank[1]
      print((paste0('C-index = ',C.index[isimul,2+i_rho,ps])))
      
      ## Uno C-index from survAUC package
      C.index_uno[isimul,2+i_rho,ps]<- survAUC::UnoC(Surv(Y_train, delta_train), Surv(Y_test, delta_test), -predicted, time =unotimes)
      print((paste0('UNO C-index = ',C.index_uno[isimul,2+i_rho,ps])))
      
      print("----------------------------------")
    } ## close over rho
  }  # close over ps
  
  } ## Close over simulation
  
  
  ## extract and print table results for each ps and all simulations
  for (ip in 1:length(pu_vec)){
   # print(paste0("Save results for dimension of single view: ",pu_vec[ip]))
    C.index.ps<-as.matrix(C.index[,,ip])
    C.index_uno.ps<-as.matrix(C.index_uno[,,ip])
    FPR.ps<-as.matrix(FPR[,,ip])
    FPR.ps<-as.matrix(FPR[,,ip])
    FPR.ps<-as.matrix(FPR[,,ip])
    FNR.ps<-as.matrix(FNR[,,ip])
    NSR.ps<-as.matrix(NSR[,,ip])
    
    colnames(C.index.ps)<-c("only U","only Z","early fusion",paste0("rho=",rho_values[2:(n_rho_values-2)]))
    file_out=paste0(dir_out,"Cindex_nsimul_",nsimul,"_model_",model,"_p_",pu_vec[ip],"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
    write.table( C.index.ps, file = file_out, sep = "\t", row.names = F, col.names = T)
    
    colnames(C.index_uno.ps)<-c("only U","only Z","early fusion",paste0("rho=",rho_values[2:(n_rho_values-2)]))
    file_out=paste0(dir_out,"Cindex_Uno_nsimul_",nsimul,"_model_",model,"_p_",pu_vec[ip],"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
    write.table(C.index_uno.ps, file = file_out, sep = "\t", row.names = F, col.names = T)
    
    colnames(FPR.ps)<-c("only U","only Z","early fusion",paste0("rho=",rho_values[2:(n_rho_values-2)]))
    file_out=paste0(dir_out,"FPR_nsimul_",nsimul,"_model_",model,"_p_",pu_vec[ip],"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
    write.table(FPR.ps, file = file_out, sep = "\t", row.names = F, col.names = T)
    
    colnames(FNR.ps)<-c("only U","only Z","early fusion",paste0("rho=",rho_values[2:(n_rho_values-2)]))
    file_out=paste0(dir_out,"FNR_nsimul_",nsimul,"_model_",model,"_p_",pu_vec[ip],"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
    write.table(FNR.ps, file = file_out, sep = "\t", row.names = F, col.names = T)
    
    colnames(NSR.ps)<-c("only U","only Z","early fusion",paste0("rho=",rho_values[2:(n_rho_values-2)]))
    file_out=paste0(dir_out,"NSR_nsimul_",nsimul,"_model_",model,"_p_",pu_vec[ip],"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
    write.table(NSR.ps, file = file_out, sep = "\t", row.names = F, col.names = T)
  }  

  End_time <- Sys.time()
  
  print(paste0("Running time: ",End_time-Start_time)) 
 
  # ## summarizing performance indexes
   Cindex.tab<-NULL
   C.index_uno.tab <-NULL
   FPR.tab <-NULL
   FNR.tab <-NULL
   NSR.tab <-NULL
  
   
   if (iplot){
     # Ensure hrbrthemes fonts are available
     if (!"Roboto Condensed" %in% names(systemfonts::system_fonts()$family)) {
       hrbrthemes::import_roboto_condensed()
     }
     
     if (requireNamespace("extrafont", quietly = TRUE)) {
       extrafont::loadfonts(device = "pdf", quiet = TRUE)
     }
   }
     
   if (iplot){
     dir_input<-paste0(getwd(),"/",folder,"/")

     for (pp in pu_vec) {
     #  print(paste0("Read results for dimension: ",pp))
       file_in <- paste0(dir_input,"Cindex_nsimul_",nsimul,"_model_",model,"_p_",pp,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
       Cindex <- read.table(file = file_in, sep = "\t",header = TRUE,check.names=FALSE)
       Cindex.tab.p <- apply(Cindex,2,mean)
       Cindex.tab  <-rbind(Cindex.tab,Cindex.tab.p)
  
       file_in <- paste0(dir_input,"Cindex_Uno_nsimul_",nsimul,"_model_",model,"_p_",pp,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
       C.index_uno <- read.table(file = file_in, sep = "\t",header = TRUE,check.names=FALSE)
       C.index_uno.tab.p <- apply( C.index_uno,2,mean)
       C.index_uno.tab  <-rbind( C.index_uno.tab,Cindex.tab.p)
  
       file_in<-paste0(dir_input,"FPR_nsimul_",nsimul,"_model_",model,"_p_",pp,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
       FPR=read.table(file = file_in, sep = "\t",header = TRUE,check.names=FALSE)
       FPR.tab.p <- apply(FPR,2,mean)
       FPR.tab  <-rbind(FPR.tab,FPR.tab.p)
  
       file_in=paste0(dir_input,"FNR_nsimul_",nsimul,"_model_",model,"_p_",pp,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
       FNR=read.table(file = file_in, sep = "\t",header = TRUE,check.names=FALSE)
       FNR.tab.p <- apply( FNR,2,mean)
       FNR.tab  <-rbind( FNR.tab,FNR.tab.p)
  
       file_in <- paste0(dir_input,"NSR_nsimul_",nsimul,"_model_",model,"_p_",pp,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
       NSR <- read.table(file = file_in, sep = "\t",header = TRUE,check.names=FALSE)
       NSR.tab.p <- apply(NSR,2,mean)
       NSR.tab  <-rbind( NSR.tab,NSR.tab.p)
     }
  
     Cindex.tab<-cbind(pu_vec+pz_vec, Cindex.tab)
     colnames( Cindex.tab)[1]<-"p"
     stargazer(Cindex.tab,summary=FALSE)
     file_out<-paste0(dir_out,"Complete_Cindex_",nsimul,"_model_",model,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
     write.table(Cindex.tab, file = file_out, sep = "\t", row.names = F, col.names = T)
     g1<-plot_measure(Cindex.tab,"Harrell's C-index",grid_step = xgrid.step,c(0.4,1))
  
     C.index_uno.tab <-cbind(pu_vec+pz_vec, C.index_uno.tab )
     colnames( C.index_uno.tab )[1]<-"p"
     stargazer(C.index_uno.tab,summary=FALSE)
     file_out<-paste0(dir_out,"Complete_Cindex_UNO_",nsimul,"_model_",model,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
     write.table(C.index_uno.tab, file = file_out, sep = "\t", row.names = F, col.names = T)
     g2<-plot_measure(C.index_uno.tab,"Uno's C-index",grid_step = xgrid.step,c(0.4,1))
  
     FPR.tab <-cbind(pu_vec+pz_vec, FPR.tab )
     colnames( FPR.tab )[1]<-"p"
     stargazer(FPR.tab,summary=FALSE)
     file_out<-paste0(dir_out,"Complete_FPR_",nsimul,"_model_",model,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
     write.table(FPR.tab, file = file_out, sep = "\t", row.names = F, col.names = T)
     g3<-plot_measure(FPR.tab,"FPR",grid_step = xgrid.step)
  
     FNR.tab <-cbind(pu_vec+pz_vec, FNR.tab )
     colnames( FNR.tab )[1]<-"p"
     stargazer(FNR.tab,summary=FALSE)
     file_out<-paste0(dir_out,"Complete_FNR_",nsimul,"_model_",model,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
     write.table(FNR.tab, file = file_out, sep = "\t", row.names = F, col.names = T)
     g4<-plot_measure(FNR.tab,"FNR",grid_step = xgrid.step)
  
     NSR.tab <-cbind(pu_vec+pz_vec, NSR.tab )
     colnames( NSR.tab )[1]<-"p"
     stargazer(NSR.tab,summary=FALSE)
     file_out<-paste0(dir_out,"Complete_NSR_",nsimul,"_model_",model,"_tu_",tu,"_tz_",tz,"_rate_",rate,"_lam_min_", lam_min,"_SNR_",snr,".txt")
     write.table(NSR.tab, file = file_out, sep = "\t", row.names = F, col.names = T)
     g5<-plot_measure(NSR.tab,"NSR",grid_step = xgrid.step)
  
     # Reduce spacing between panels
     g1 <- g1 + theme(plot.margin = margin(5,2,5,2))
     g2 <- g2 + theme(plot.margin = margin(5,2,5,2))
     g3 <- g3 + theme(plot.margin = margin(5,2,5,2))
     g4 <- g4 + theme(plot.margin = margin(5,2,5,2))
     g5 <- g5 + theme(plot.margin = margin(5,2,5,2))
  
     # Combine panels with shared legend
     combined_plot_H <- ggpubr::ggarrange(
       g1, g2, g3, g4, g5,
       ncol = 5,
       nrow = 1,
       common.legend = legend.plot,
       legend = (if(legend.plot) "top" else "none")
     )
  
     ggsave(
       filename = paste0(
         dir_out,"Figure_additional_",nsimul,"_model_",model,"_tu_",tu,"_tz_",tz,"_rate_",rate,
         "_lam_min_",lam_min,"_SNR_",snr, ".pdf"),
       plot = combined_plot_H,
       width = 15,
       height = 4,
       device = cairo_pdf
     )
   }
}