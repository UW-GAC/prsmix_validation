# prsmix_validation

Workflows for validation of PRSMix Legacy project models

## weighted_sum_scores

Calculate a new score using a weighted sum of existing scores


## adjust_scores

Adjust a score for ancestry


## pgsmetrics

Calculate PGS metrics for a score


## Docker image

Build the docker image:

```
docker build --platform="linux/amd64" --no-cache -f pgsmetrics.dockerfile -t uwgac/pgsmetrics:X.Y.Z .
```

Push the docker image:

```
docker push uwgac/pgsmetrics:X.Y.Z
```
