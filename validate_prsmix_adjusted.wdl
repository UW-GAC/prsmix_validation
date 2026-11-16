version 1.0

import "https://raw.githubusercontent.com/UW-GAC/prsmix_validation/refs/heads/combined-workflows/weighted_sum_scores.wdl" as weighted_sum_scores
import "https://raw.githubusercontent.com/UW-GAC/prsmix_validation/refs/heads/combined-workflows/pgsmetrics.wdl" as pgsmetrics
import "https://raw.githubusercontent.com/UW-GAC/prsmix_validation/refs/heads/combined-workflows/pgsmetrics_by_cluster.wdl" as pgsmetrics_by_cluster

workflow validate_prsmix_adjusted {
    input {
        File weight_file
        File adjusted_scores_file
        File phenotype_file
        String trait_name
        File cluster_file
        String? covariates
    }

    call weighted_sum_scores.weighted_sum_scores {
        input:
            weights = weight_file,
            scores = adjusted_scores_file
    }

    call pgsmetrics.pgsmetrics {
        input:
            score_file = weighted_sum_scores.outfile,
            phenotype_file = phenotype_file,
            trait_name = trait_name,
            covariates = covariates
    }

    call pgsmetrics_by_cluster.pgsmetrics_by_cluster {
        input:
            cluster_file = cluster_file,
            score_file = weighted_sum_scores.outfile,
            phenotype_file = phenotype_file,
            trait_name = trait_name,
            covariates = covariates
    }

    output {
        File adjusted_scores = weighted_sum_scores.outfile
        File pgs_metrics = pgsmetrics.pgs_metrics
        File full_pgs_metrics = pgsmetrics.full_pgs_metrics
        File effect_metrics = pgsmetrics.effect_metrics
        File combined_pgs_metrics_by_cluster = pgsmetrics_by_cluster.combined_pgs_metrics
        Array[File] full_pgs_metrics_by_cluster = pgsmetrics_by_cluster.full_pgs_metrics
        File combined_effect_metrics_by_cluster = pgsmetrics_by_cluster.combined_effect_metrics
    }
}
