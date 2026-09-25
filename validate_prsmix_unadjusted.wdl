version 1.0

import "https://raw.githubusercontent.com/UW-GAC/prsmix_validation/refs/heads/main/weighted_sum_scores.wdl" as weighted_sum_scores
import "https://raw.githubusercontent.com/UW-GAC/prsmix_validation/refs/heads/main/adjust_scores_pcs.wdl" as adjust_scores_pcs
import "https://raw.githubusercontent.com/UW-GAC/prsmix_validation/refs/heads/main/pgsmetrics.wdl" as pgsmetrics

workflow validate_prsmix_unadjusted {
    input {
        File weight_file
        File unadjusted_scores_file
        File pc_file
        File phenotype_file
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

    output {
        File adjusted_scores = adjust_scores_pcs.adjusted_scores
        File pgs_metrics = pgsmetrics.pgs_metrics
        File effect_metrics = pgsmetrics.effect_metrics
    }
}
