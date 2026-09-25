version 1.0

import "https://raw.githubusercontent.com/UW-GAC/prsmix_validation/refs/heads/main/weighted_sum_scores.wdl" as weighted_sum_scores
import "https://raw.githubusercontent.com/UW-GAC/prsmix_validation/refs/heads/main/pgsmetrics.wdl" as pgsmetrics

workflow validate_prsmix_adjusted {
    input {
        File weight_file
        File adjusted_scores_file
        File pc_file
        File phenotype_file
        String trait_name
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

    output {
        File adjusted_scores = weighted_sum_scores.outfile
        File pgs_metrics = pgsmetrics.pgs_metrics
        File effect_metrics = pgsmetrics.effect_metrics
    }
}
