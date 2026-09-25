version 1.0

workflow adjust_scores_pcs {
    input {
        File scores
        File pcs
        File? sample_include_file
    }

    call adjust_prs {
        input:
            scores = scores,
            pcs = pcs,
            sample_include_file = sample_include_file
    }

    output {
        File adjusted_scores = adjust_prs.adjusted_scores
    }
}

task adjust_prs {
    input {
        File scores
        File pcs
        File? sample_include_file
        Int mem_gb = 16
    }

    Int disk_size = ceil(2.5*(size(scores, "GB") + size(pcs, "GB"))) + 10

    command <<<
        R << RSCRIPT
        library(tidyverse)
        source("/usr/local/ancestry_adjustment.R")

        scores <- read_tsv('~{scores}')
        pcs <- read_tsv('~{pcs}')

        # If a sample_include_file is provided, filter the scores and pcs to only include those samples
        if (file.exists("~{sample_include_file}")) {
            print("Filtering samples based on sample_include_file: ~{sample_include_file}")
            sample_include <- readLines('~{sample_include_file}')
            scores = scores %>% filter(IID %in% sample_include)
            pcs = pcs %>% filter(IID %in% sample_include)
        }

        model <- fit_prs(scores, pcs)
        mean_coef <- model[['mean_coef']]
        var_coef <- model[['var_coef']]
        adjusted_scores <- adjust_prs(scores, pcs, mean_coef, var_coef)
        write_tsv(adjusted_scores, 'adjusted_scores.txt')
        RSCRIPT
    >>>

    output {
        File adjusted_scores = "adjusted_scores.txt"
    }

    runtime {
        docker: "uwgac/pgsmetrics:0.1.0"
        disks: "local-disk ~{disk_size} SSD"
        memory: "~{mem_gb}G"
    }
}
