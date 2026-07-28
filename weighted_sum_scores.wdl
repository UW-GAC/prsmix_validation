version 1.0

workflow weighted_sum_scores {
    input {
        File weights
        File scores
    }

    call weighted_sum {
        input:
            weights = weights,
            scores = scores
    }

    output {
        File outfile = weighted_sum.outfile
    }
}


task weighted_sum {
    input {
        File weights
        File scores
        Int mem_gb = 8
    }

    Int disk_size = ceil(2*(size(weights, "GB") + size(scores, "GB"))) + 10

    command <<<
    R << RSCRIPT
    library(readr)
    scores <- read_tsv("~{scores}")
    weights <- read_tsv("~{weights}")
    wts <- setNames(weights[["weight"]], weights[["score"]])
    colnames(scores) <- sub("_SUM", "", colnames(scores))
    stopifnot(all(names(wts) %in% colnames(scores)))
    matched_scores <- scores[,names(wts)]
    weighted_scores <- sweep(as.matrix(matched_scores), MARGIN=2, STATS=wts, FUN="*")
    wtd <- rowSums(weighted_scores, na.rm=TRUE)
    out <- tibble::tibble(IID = scores[[1]], score = wtd)
    write_tsv(out, "weighted_sum.txt")
    RSCRIPT
    >>>

    output {
        File outfile = "weighted_sum.txt"
    }

    runtime {
        docker: "rocker/tidyverse:4"
        disks: "local-disk ~{disk_size} SSD"
        memory: "~{mem_gb}G"
    }
}
