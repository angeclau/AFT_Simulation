# =============================================================================
# MakeMainSimulationTables
#
# Assemble the partial results saved in OUTPUT_SNR_0.8 into:
#
# Table 2  : Weibull model
# Table S1 : Log-normal model
# Table S2 : Log-logistic model
#
# Results are saved in:
# OUTPUT_SNR_0.8/MainSimulationTables
# =============================================================================

MakeMainSimulationTables <- function(tableFolder = "MainSimulationTables",
                                     snr = 0.8){
  
  library(dplyr)
  library(purrr)
  library(stringr)
  
  mypath <- getwd()
  
  myfolder <- paste0("OUTPUT_SNR_", snr)
  
  input_folder <- file.path(mypath, myfolder)
  
  output_folder <- file.path(
    mypath,
    myfolder,
    tableFolder
  )
  
  dir.create(
    output_folder,
    recursive = TRUE,
    showWarnings = FALSE
  )
  
  # ===========================================================================
  # Read all files
  # ===========================================================================
  
  files <- list.files(
    path = input_folder,
    pattern = "^Table_Err.*\\.txt$",
    full.names = TRUE
  )
  
  
  read_result_file <- function(file){
    
    fname <- basename(file)
    
    model <- str_match(fname, "model_([^_]+)")[,2]
    weak  <- str_match(fname, "weak_(TRUE|FALSE)")[,2]
    tu    <- as.numeric(str_match(fname, "tu_([0-9]+)")[,2])
    tz    <- as.numeric(str_match(fname, "tz_([0-9]+)")[,2])
    
    x <- read.delim(
      file,
      sep = "\t",
      check.names = FALSE,
      stringsAsFactors = FALSE
    )
    
    names(x)[1] <- "Index"
    
    # Fix common encoding issues
    x$Index <- iconv(x$Index, to = "UTF-8")
    
    x$Index <- gsub(
      "Harrellâ€™s C-index",
      "Harrell's C-index",
      x$Index,
      fixed = TRUE
    )
    
    x <- x %>%
      mutate(
        model = model,
        weak  = weak,
        tu    = tu,
        tz    = tz
      )
    
    return(x)
  }
  
  dat <- map_dfr(files, read_result_file)
  
  # ===========================================================================
  # Create one LaTeX table
  # ===========================================================================
  
  create_table <- function(model_name,
                           table_name,
                           caption_text,
                           dat){
    
    methods <- c(
      "only U",
      "only Z",
      "early fusion",
      "rho=0.25",
      "rho=0.5",
      "rho=0.75"
    )
    
    metrics <- c(
      "Harrell's C-index",
      "Uno's C-index",
      "FPR",
      "FNR",
      "NSR"
    )
    
    df <- dat %>%
      filter(model == model_name)
    
    tz_values <- sort(
      unique(df$tz),
      decreasing = TRUE
    )
    
    tu_value <- unique(df$tu)[1]
    
    body <- c()
    
    for(tzv in tz_values){
      
      weak_tab <- df %>%
        filter(
          weak == "TRUE",
          tz == tzv
        )
      
      strong_tab <- df %>%
        filter(
          weak == "FALSE",
          tz == tzv
        )
      
      body <- c(
        body,
        "& & & & & & & & & & & & & \\\\"
      )
      
      for(i in seq_along(metrics)){
        
        metric <- metrics[i]
        
        left <- weak_tab %>%
          filter(Index == metric) %>%
          select(all_of(methods)) %>%
          unlist(use.names = FALSE)
        
        right <- strong_tab %>%
          filter(Index == metric) %>%
          select(all_of(methods)) %>%
          unlist(use.names = FALSE)
        
        case_label <- ""
        
        if(i == 3){
          case_label <- paste0("$t_u=", tu_value, "$")
        }
        
        if(i == 4){
          case_label <- paste0("$t_z=", tzv, "$")
        }
        
        row <- paste0(
          case_label,
          " & {\\bf ", metric, "} & ",
          paste(
            sprintf("%.3f", c(left, right)),
            collapse = " & "
          ),
          " \\\\"
        )
        
        body <- c(body, row)
      }
      
      body <- c(
        body,
        "& & & & & & & & & & & & & \\\\",
        "\\hline"
      )
    }
    
    tex <- paste0(
      "\\begin{table}[!htbp]
\\centering
\\tiny
\\caption{", caption_text, "}
\\label{tab:", table_name, "}
\\begin{tabular}{c|c|cccccc|cccccc}

\\multicolumn{1}{c}{} &
\\multicolumn{1}{c}{} &
\\multicolumn{6}{c}{\\bf weak effect of high dimensionality} &
\\multicolumn{6}{c}{\\bf strong effect of high dimensionality} \\\\

[1ex]
\\hline

& & & & & & & & & & & & & \\\\

{\\bf Case} &
{\\bf Index} &
{\\bf only U} &
{\\bf only Z} &
{\\bf early fusion} &
{\\bf $\\rho$=0.25} &
{\\bf $\\rho$=0.5} &
{\\bf $\\rho$=0.75} &
{\\bf only U} &
{\\bf only Z} &
{\\bf early fusion} &
{\\bf $\\rho$=0.25} &
{\\bf $\\rho$=0.5} &
{\\bf $\\rho$=0.75} \\\\

& & & & & & & & & & & & & \\\\

\\hline
",
      paste(body, collapse = "\n"),
      "
\\end{tabular}
\\end{table}"
    )
    
    return(tex)
  }
  
  # ===========================================================================
  # Models and manuscript table names
  # ===========================================================================
  
  models <- c(
    "weibull",
    "lognormal",
    "loglogistic"
  )
  
  table_names <- c(
    "Table2",
    "TableS1",
    "TableS2"
  )
  
  captions <- c(
    "Performance measures for the Weibull model, averaged over 50 independent replications.",
    "Performance measures for the Log-normal model, averaged over 50 independent replications.",
    "Performance measures for the Log-logistic model, averaged over 50 independent replications."
  )
  
  # ===========================================================================
  # Generate tables
  # ===========================================================================
  
  for(i in seq_along(models)){
    
    cat("\n")
    cat(rep("=",80), sep="")
    cat("\n")
    cat("Processing ", table_names[i],
        " (", models[i], ")\n", sep="")
    cat(rep("=",80), sep="")
    cat("\n\n")
    
    tex <- create_table(
      model_name  = models[i],
      table_name  = table_names[i],
      caption_text = captions[i],
      dat = dat
    )
    
    writeLines(
      tex,
      file.path(
        output_folder,
        paste0(table_names[i], ".tex")
      )
    )
    
    # Print table in console
    cat(tex)
    cat("\n\n")
  }
  
  cat("\nDone!\n")
  
}