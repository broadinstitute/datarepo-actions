#!/bin/bash

alpharelease () {
  if [[ -n "${alpharelease}" ]]; then
    printf "Running alpharelease for tag ${alpharelease}"
    cd jade-data-repo-ui
    uitag=$(git rev-parse --short HEAD)
    # echo "::set-output name=ui-tag::$ui-tag"
    gcloud container images add-tag gcr.io/broad-jade-dev/jade-data-repo-ui:${uitag} \
      gcr.io/broad-jade-dev/jade-data-repo-ui:"${alpharelease}-alpha"
    gradlebuild
  else
    printf "alpha release not sucessful missing vars"
    exit 1
  fi
}
