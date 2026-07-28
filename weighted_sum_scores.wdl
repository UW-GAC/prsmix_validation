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
    }


    command <<<
    library(tidyverse)
    scores <- read_tsv("${scores}")
    weights <- read_tsv("${weights}")
    wts <- setNames(weights$weight, weights$score)
    stopifnot(all(names(weights) %in% colnames(scores)))
    matched_scores <- scores[,names(weights)]
    weighted_scores <- sweep(as.matrix(matched_scores), MARGIN=2, STATS=weights, FUN="*")
    wtd <- rowSums(weighted_scores, na.rm=TRUE)
    write_tsv(wtd, "weighted_sum.txt")
    >>>

    output {
        File outfile = "weighted_sum.txt"
    }

    runtime {
        docker: "rocker/tidyverse:4"
        disks: "local-disk 16 SSD"
        memory: "8G"
    }
}
