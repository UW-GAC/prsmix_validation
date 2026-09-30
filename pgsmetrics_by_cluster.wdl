version 1.0

import "https://raw.githubusercontent.com/UW-GAC/prsmix_validation/refs/heads/main/pgsmetrics.wdl" as pgsmetrics

workflow pgsmetrics_by_cluster {
    input {
        File cluster_file
        Int min_samples_per_cluster=50
        File score_file
        File phenotype_file
        String trait_name
        String? covariates
    }

    call get_samples_by_cluster {
        input:
            cluster_file = cluster_file,
            phenotype_file = phenotype_file,
            min_samples_per_cluster = min_samples_per_cluster
    }

    scatter(sample_include_file in get_samples_by_cluster.sample_include_files) {
        call pgsmetrics.run_metrics {
            input:
                score_file = score_file,
                phenotype_file = phenotype_file,
                covariates = covariates,
                sample_include_file = sample_include_file,
                trait_name = trait_name
        }
    }

    output {
        Array[File] pgs_metrics = run_metrics.pgs_metrics
        Array[File] effect_metrics = run_metrics.effect_metrics
    }

}


task get_samples_by_cluster {

    input {
        File cluster_file
        File phenotype_file
        Int min_samples_per_cluster
    }

    command <<<
    R << RSCRIPT
    library(tidyverse)
    library(data.table)

    clusters = read_tsv("~{cluster_file}") %>% select(IID, best_cluster)
    phenotype_file = read_tsv("~{phenotype_file}") %>% select(IID)
    clusters = clusters %>% filter(IID %in% phenotype_file$IID)

    clusters %>% group_by(best_cluster) %>% count()
    clist = clusters %>% group_by(best_cluster) %>% mutate(n=n()) %>% filter(n >= ~{min_samples_per_cluster}) %>% group_split()
    lapply(clist, nrow)

    # Write out files for each cluster
    for (i in seq_along(clist)) {
        cluster = clist[[i]]
        cluster_name = unique(cluster$best_cluster)
        write_tsv(cluster, paste0("sample_include_cluster_", cluster_name, ".txt"))
    }
    RSCRIPT
    >>>

    output {
        Array[File] sample_include_files = glob("sample_include_*.txt")
    }

    runtime {
        docker: "uwgac/pgsmetrics:0.1.0"
        disks: "local-disk 10 SSD"
        memory: "4G"
        cpu: "1"
    }
}
