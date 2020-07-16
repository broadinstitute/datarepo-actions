#!/bin/bash

alpharelease () {
  if [[ -n "${alpharelease}" ]] && [[ -n "${DEV_PROJECT}" ]]; then
    printf "Running alpharelease for tag ${alpharelease}\n"
    uitag=$(git -C jade-data-repo-ui rev-parse --short HEAD)
    # echo "::set-output name=ui-tag::$ui-tag"
    gcloud container images add-tag gcr.io/broad-jade-dev/jade-data-repo-ui:${uitag} \
      gcr.io/broad-jade-dev/jade-data-repo-ui:"${alpharelease}-alpha" --quiet
    # source and run gradlebuild
    source ${scriptDir}/gradlebuild.sh
    gradlebuild "${DEV_PROJECT}"
  else
    printf "alpha release not sucessful missing vars"
    exit 1
  fi
}
