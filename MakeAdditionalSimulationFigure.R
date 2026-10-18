# =============================================================================
# MakeAdditionalSimulationFigure
#
# Assemble the partial results saved in Additional_OUTPUT into:
#
# Figure 4
# Results are saved in:
# Additional_OUTPUT/SimulationFigure
# =============================================================================

MakeAdditionalSimulationFigure <- function(figureFolder = "SimulationFigure"){
  
library(magick)
  
mypath<-getwd()
myfolder<-"Additional_OUTPUT"

  
dir.create(paste(mypath,myfolder,figureFolder,sep="/"), showWarnings = FALSE)

### Figure for the Weibull model 
# Read preliminary pdf for Figure 1 
p1 <- image_read_pdf(paste(mypath,myfolder,"Figure_additional_50_model_weibull_tu_6_tz_6_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p2 <- image_read_pdf(paste(mypath,myfolder,"Figure_additional_50_model_weibull_tu_6_tz_4_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p3 <- image_read_pdf(paste(mypath,myfolder,"Figure_additional_50_model_weibull_tu_6_tz_2_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
p4 <- image_read_pdf(paste(mypath,myfolder,"Figure_additional_50_model_weibull_tu_6_tz_0_rate_40_lam_min_FALSE_SNR_0.8.pdf",sep="/"), density = 300)
#
# 
final_fig <- image_append(
  c(p1, p2, p3, p4),
  stack = TRUE
)

image_write(
  final_fig,
  paste(mypath,myfolder,figureFolder,"Figure3.png",sep="/")
)

}