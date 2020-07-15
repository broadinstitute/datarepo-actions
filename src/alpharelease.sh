#!/bin/bash

alpharelease () {
  if [[ -n "${alpharelease}" ]] && [[ -n "${gcr_google_project}" ]]; then
    cd jade-data-repo-ui
    uitag=$(git rev-parse --short HEAD)
    # echo "::set-output name=ui-tag::$ui-tag"
    gcloud container images add-tag gcr.io/broad-jade-dev/jade-data-repo-ui:${uitag} \
      gcr.io/broad-jade-dev/jade-data-repo-ui:"${alpharelease}-alpha"
    gradlebuild
  fi
}
