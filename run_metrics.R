library(pgsmetrics)
library(tidyverse)
library(argparser)

args <- commandArgs(trailingOnly = TRUE)

p <- arg_parser("Run PGS metrics")

# Add command line arguments
p <- add_argument(p, "--score-file", help="Path to the score file")
p <- add_argument(p, "--phenotype-file", help="Path to the phenotype file")
p <- add_argument(p, "--trait-name", help="Name of the trait")
p <- add_argument(p, "--covariates", help="Comma-separated list of covariates", default="")
p <- add_argument(p, "--cpu", help="Number of CPU cores", type="integer", default=1)

# Parse the command line arguments
argv <- parse_args(p)

score_file <- argv$score_file
phenotype_file <- argv$phenotype_file
trait_name <- argv$trait_name
covariates <- argv$covariates
cpu <- as.integer(argv$cpu)

score <- read_tsv(score_file)
phenotypes <- read_tsv(phenotype_file)

covars = str_split(argv$covariates, ",")[[1]]

phenotypes = phenotypes %>%
  select(IID, all_of(trait_name), all_of(covars))

dat <- score %>%
  inner_join(phenotypes)

metrics <- pgsmetrics(
    as.data.table(dat),
    pgs = "score",
    dep = trait_name,
    covars = covars,
    n_cores = cpu
)
write_tsv(metrics$metrics, "pgs_metrics.txt")

eff_metrics <- effects_pgsmetrics(
    as.data.table(dat),
    pgs = "score",
    dep = trait_name,
    covars = covars,
    report_covars = TRUE
)
write_tsv(eff_metrics, "effect_metrics.txt")
