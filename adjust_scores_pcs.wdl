version 1.0

workflow adjust_scores_pcs {
    input {
        File scores
        File pcs
    }

    call adjust_prs {
        input:
            scores = scores,
            pcs = pcs
    }

    output {
        File adjusted_scores = adjust_prs.adjusted_scores
    }
}

task adjust_prs {
    input {
        File scores
        File pcs
        File ancestry_script = "https://raw.githubusercontent.com/UW-GAC/pgsc_calc_wdl/refs/heads/main/ancestry_adjustment.R"
        Int mem_gb = 16
    }

    Int disk_size = ceil(2.5*(size(scores, "GB") + size(pcs, "GB"))) + 10

    command <<<
        R << RSCRIPT
        library(tidyverse)
        source('~{ancestry_script}')
        scores <- read_tsv('~{scores}')
        pcs <- read_tsv('~{pcs}')
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
        docker: "rocker/tidyverse:4"
        disks: "local-disk ~{disk_size} SSD"
        memory: "~{mem_gb}G"
    }
}
