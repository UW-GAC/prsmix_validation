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

        call add_cluster_id {
            input:
                sample_include_filename = sample_include_file,
                pgs_metrics_file = run_metrics.pgs_metrics,
                effect_metrics_file = run_metrics.effect_metrics
        }
    }

    output {
        Array[File] pgs_metrics = add_cluster_id.pgs_metrics_with_cluster
        Array[File] effect_metrics = add_cluster_id.effect_metrics_with_cluster
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
    clusters = clusters %>% filter(IID %in% phenotype_file[["IID"]])

    clusters %>% group_by(best_cluster) %>% count()
    clist = clusters %>% group_by(best_cluster) %>% mutate(n=n()) %>% filter(n >= ~{min_samples_per_cluster}) %>% group_split()
    lapply(clist, nrow)

    # Write out files for each cluster
    for (i in seq_along(clist)) {
        cluster = clist[[i]]
        cluster_name = unique(cluster[["best_cluster"]])
        writeLines(as.character(cluster[["IID"]]), paste0("sample_include_cluster_", cluster_name, ".txt"))
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

task add_cluster_id {
    input {
        String sample_include_filename
        File pgs_metrics_file
        File effect_metrics_file
    }

    command <<<
    R << RSCRIPT
    library(tidyverse)
    cluster_id = str_extract(basename("~{sample_include_filename}"), "(?<=sample_include_cluster_)[^\\.]+")
    read_tsv("~{pgs_metrics_file}") %>% mutate(cluster_id = cluster_id) %>% write_tsv("pgs_metrics_with_cluster.txt")
    read_tsv("~{effect_metrics_file}") %>% mutate(cluster_id = cluster_id) %>% write_tsv("effect_metrics_with_cluster.txt")
    RSCRIPT
    >>>

    output {
        File pgs_metrics_with_cluster = "pgs_metrics_with_cluster.txt"
        File effect_metrics_with_cluster = "effect_metrics_with_cluster.txt"
    }

    runtime {
        docker: "uwgac/pgsmetrics:0.1.0"
        disks: "local-disk 10 SSD"
        memory: "4G"
        cpu: "1"
    }
}
