library(pgsmetrics)
library(tidyverse)

args <- commandArgs(trailingOnly = TRUE)

score_file <- args[1]
trait_file <- args[2]
covar_file <- args[3]
cpu <- as.integer(args[4])

score <- read_tsv(score_file)
trait <- read_tsv(trait_file)
covars <- read_tsv(covar_file)

dat <- score %>%
  inner_join(trait) %>%
  inner_join(covars)

metrics <- pgsmetrics(
  as.data.table(dat), 
  pgs = "score",
  dep = setdiff(names(trait), "IID"),
  covars = setdiff(names(covars), "IID"),
  n_cores = cpu
)
write_tsv(metrics$metrics, "pgs_metrics.txt")

eff_metrics <- effects_pgsmetrics(
  as.data.table(dat), 
  pgs = "score",
  dep = setdiff(names(trait), "IID"),
  covars = setdiff(names(covars), "IID"),
  report_covars = TRUE
)
write_tsv(eff_metrics, "effect_metrics.txt")
