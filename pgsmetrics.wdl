version 1.0

workflow pgsmetrics {
    input {
        File scores
        File trait
        File covariates
    }

    call run_metrics {
        input:
            scores = scores,
            trait = trait,
            covariates = covariates
    }

    output {
        File pgs_metrics = run_metrics.pgs_metrics
        File effect_metrics = run_metrics.effect_metrics
    }
}


task run_metrics {
    input {
        File scores
        File trait
        File covariates
        Int mem_gb = 8
        Int cpu = 2
    }

    Int disk_size = ceil(2*(size(scores, "GB") + size(trait, "GB") + size(covariates, "GB"))) + 10

    command <<<
    wget https://raw.githubusercontent.com/UW-GAC/prsmix_validation/refs/heads/main/run_metrics.R
    Rscript run_metrics.R \
        ~{scores} \
        ~{trait} \
        ~{covariates} \
        ~{cpu}
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
