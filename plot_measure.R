plot_measure <- function(table, name, grid_step = 150, yrange = c(0,1)){
  
  library(tidyverse)
  library(hrbrthemes)

  #library(extrafont)
  #font_import()
  #loadfonts(device="pdf")
  
  # color palette for methods
  my_palette <- c(
    "only U" = "#4477AA",
    "only Z" = "#66CCEE",
    "early fusion" = "#228833",
    "rho=0.25" = "#CCBB44",
    "rho=0.5" = "#AA3377",
    "rho=0.75" = "#EE6677"
  )
  
  df <- as.data.frame(table) %>%
    pivot_longer(
      cols = -p,
      names_to = "method",
      values_to = "index"
    )
  
  df$method <- factor(
    df$method,
    levels = c("only U","only Z","early fusion",
               "rho=0.25","rho=0.5","rho=0.75")
  )
  
  g <- ggplot(df, aes(x = p, y = index, color = method)) +
    geom_point(size = 2) +
    geom_line(linewidth = 1) +
    scale_color_manual(
      values = my_palette,
      labels = c(
        "only U",
        "only Z",
        "early fusion",
        expression(rho==0.25),
        expression(rho==0.50),
        expression(rho==0.75)
      )
    )+
    scale_x_continuous(
      breaks = seq(min(df$p), max(df$p), by = grid_step)
    ) +
    scale_y_continuous(limits = yrange) +
    theme_ipsum() +
    theme(
      legend.position = "top",
      legend.title = element_blank(),
      legend.text = element_text(size = 9),
      plot.title = element_text(size = 11),
      axis.text.x = element_text(angle = 45, hjust = 1)
    ) +
    labs(
      title = name,
      x = "",
      y = ""
    )
  
  return(g)
}

