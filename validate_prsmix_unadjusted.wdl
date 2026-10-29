version 1.0

import "https://raw.githubusercontent.com/UW-GAC/prsmix_validation/refs/heads/combined-workflows/weighted_sum_scores.wdl" as weighted_sum_scores
import "https://raw.githubusercontent.com/UW-GAC/prsmix_validation/refs/heads/combined-workflows/adjust_scores_pcs.wdl" as adjust_scores_pcs
import "https://raw.githubusercontent.com/UW-GAC/prsmix_validation/refs/heads/combined-workflows/pgsmetrics.wdl" as pgsmetrics
import "https://raw.githubusercontent.com/UW-GAC/prsmix_validation/refs/heads/combined-workflows/pgsmetrics_by_cluster.wdl" as pgsmetrics_by_cluster

workflow validate_prsmix_unadjusted {
    input {
        File weight_file
        File unadjusted_scores_file
        File pc_file
        File phenotype_file
        File cluster_file
        String trait_name
        String? covariates
    }

    call weighted_sum_scores.weighted_sum_scores {
        input:
            weights = weight_file,
            scores = unadjusted_scores_file
    }

    call adjust_scores_pcs.adjust_scores_pcs {
        input:
            scores = weighted_sum_scores.outfile,
            pcs = pc_file,
    }

    call pgsmetrics.pgsmetrics {
        input:
            score_file = adjust_scores_pcs.adjusted_scores,
            phenotype_file = phenotype_file,
            trait_name = trait_name,
            covariates = covariates
    }

    call pgsmetrics_by_cluster.pgsmetrics_by_cluster {
        input:
            cluster_file = cluster_file,
            score_file = adjust_scores_pcs.adjusted_scores,
            phenotype_file = phenotype_file,
            trait_name = trait_name,
            covariates = covariates
    }

    output {
        File adjusted_scores = adjust_scores_pcs.adjusted_scores
        File pgs_metrics = pgsmetrics.pgs_metrics
        File full_pgs_metrics = pgsmetrics.full_pgs_metrics
        File effect_metrics = pgsmetrics.effect_metrics
        File pgs_metrics_by_cluster = pgsmetrics_by_cluster.pgs_metrics_by_cluster
        File effect_metrics_by_cluster = pgsmetrics_by_cluster.effect_metrics_by_cluster
    }
}
