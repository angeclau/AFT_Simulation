# =============================================================================
# MakeMainSimulationFigures
#
# Assemble the partial results saved in OUTPUT_SNR_0.8 into:
#
# Figure 2 and Figure 3: Weibull model (weak<-T and weak<-F, respectively)
# Figure S1 and Figure S2: Log-normal model  (weak<-T and weak<-F, respectively)
# Figure S3 and Figure S2: Log-logistic model  (weak<-T and weak<-F, respectively)
#
# Results are saved in:
# OUTPUT_SNR_0.8/MainSimulationFigures
# =============================================================================

MakeMainSimulationFigures <- function(figureFolder = "MainSimulationFigures"){
  
library(magick)
  
mypath<-getwd()
myfolder<-"OUTPUT_SNR"
snr <- 0.8
myfolder<-paste(myfolder,snr,sep="_")
  
dir.create(paste(mypath,myfolder,figureFolder,sep="/"), showWarnings = FALSE)

### Figure for the Weibull model 
# Read preliminary pdf for Figure 2 
p1 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_weibull_weak_FALSE_tu_6_tz_6_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p2 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_weibull_weak_FALSE_tu_6_tz_4_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p3 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_weibull_weak_FALSE_tu_6_tz_2_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p4 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_weibull_weak_FALSE_tu_6_tz_0_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
#
# 
final_fig <- image_append(
  c(p1, p2, p3, p4),
  stack = TRUE
)


image_write(
  final_fig,
  paste(mypath,myfolder,figureFolder,"Figure2.png",sep="/")
)

# Read preliminary pdf for Figure 2 
p1 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_weibull_weak_TRUE_tu_6_tz_6_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p2 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_weibull_weak_TRUE_tu_6_tz_4_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p3 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_weibull_weak_TRUE_tu_6_tz_2_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p4 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_weibull_weak_TRUE_tu_6_tz_0_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
#
# 
final_fig <- image_append(
  c(p1, p2, p3, p4),
  stack = TRUE
)

image_write(
  final_fig,
  paste(mypath,myfolder,figureFolder,"Figure1.png",sep="/")
)


### Figure for the log-normal model
# Read preliminary pdf for Figure S2 

p1 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_lognormal_weak_FALSE_tu_6_tz_6_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p2 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_lognormal_weak_FALSE_tu_6_tz_4_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p3 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_lognormal_weak_FALSE_tu_6_tz_2_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p4 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_lognormal_weak_FALSE_tu_6_tz_0_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
#
# 
final_fig <- image_append(
  c(p1, p2, p3, p4),
  stack = TRUE
)

image_write(
  final_fig,
  paste(mypath,myfolder,figureFolder,"FigureS2.png",sep="/")
)

# Read preliminary pdf for Figure S1 
p1 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_lognormal_weak_TRUE_tu_6_tz_6_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p2 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_lognormal_weak_TRUE_tu_6_tz_4_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p3 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_lognormal_weak_TRUE_tu_6_tz_2_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p4 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_lognormal_weak_TRUE_tu_6_tz_0_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
#
# 
final_fig <- image_append(
  c(p1, p2, p3, p4),
  stack = TRUE
)

image_write(
  final_fig,
  paste(mypath,myfolder,figureFolder,"FigureS1.png",sep="/")
)


### Figure for the loglogistic model
# Read preliminary pdf for Figure S3 

p1 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_loglogistic_weak_FALSE_tu_6_tz_6_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p2 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_loglogistic_weak_FALSE_tu_6_tz_4_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p3 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_loglogistic_weak_FALSE_tu_6_tz_2_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p4 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_loglogistic_weak_FALSE_tu_6_tz_0_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
#
# 
final_fig <- image_append(
  c(p1, p2, p3, p4),
  stack = TRUE
)


image_write(
  final_fig,
  paste(mypath,myfolder,figureFolder,"FigureS4.png",sep="/")
)

# Read preliminary pdf for Figure S3 
p1 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_loglogistic_weak_TRUE_tu_6_tz_6_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p2 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_loglogistic_weak_TRUE_tu_6_tz_4_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p3 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_loglogistic_weak_TRUE_tu_6_tz_2_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p4 <- image_read_pdf(paste(mypath,myfolder,"Boxplot_nsimul_50_model_loglogistic_weak_TRUE_tu_6_tz_0_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
#
# 
final_fig <- image_append(
  c(p1, p2, p3, p4),
  stack = TRUE
)

image_write(
  final_fig,
  paste(mypath,myfolder,figureFolder,"FigureS3.png",sep="/")
)
}