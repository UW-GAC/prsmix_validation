version 1.0

workflow pgsmetrics {
    input {
        File scores
        File phenotype_file
        String trait_name
        String covariates
    }

    call run_metrics {
        input:
            scores = scores,
            phenotype_file = phenotype_file,
            covariates = covariates,
            trait_name = trait_name
    }

    output {
        File pgs_metrics = run_metrics.pgs_metrics
        File effect_metrics = run_metrics.effect_metrics
    }
}


task run_metrics {
    input {
        File scores
        File phenotype_file
        String trait_name
        String covariates
        Int mem_gb = 8
        Int cpu = 2
    }

    Int disk_size = ceil(2*(size(scores, "GB") + size(phenotype_file, "GB"))) + 10

    command <<<
        Rscript /usr/local/prsmix_validation/run_metrics.R \
        --score-file ~{scores} \
        --phenotype-file ~{phenotype_file} \
        --trait-name ~{trait_name} \
        --covariates ~{covariates} \
        --cpu ~{cpu}
    >>>

    output {
        File pgs_metrics = "pgs_metrics.txt"
        File effect_metrics = "effect_metrics.txt"
    }

    runtime {
        docker: "uwgac/pgsmetrics:0.1.0"
        disks: "local-disk ~{disk_size} SSD"
        memory: "~{mem_gb}G"
        cpu: "~{cpu}"
    }
}
