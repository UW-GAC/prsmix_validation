# prsmix_validation

workflows for validation of PRSMix Legacy project models

## Docker image

Build the docker image:

```
docker build --platform="linux/amd64" --no-cache -f pgsmetrics.dockerfile -t uwgac/pgsmetrics:X.Y.Z .
```

Push the docker image:

```
docker push uwgac/pgsmetrics:X.Y.Z
```
