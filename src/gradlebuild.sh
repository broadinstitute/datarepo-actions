#!/bin/bash

gradlebuild () {
  if [[ $1 -n ]]; then
    DEV_PROJECT=$1
  fi
  if [[ "${gcr_google_project}" != "" ]]; then
    export GOOGLE_APPLICATION_CREDENTIALS=jade-dev-account.json
    if [[ -n "${alpharelease}" ]]; then
      GCR_TAG="${alpharelease}-alpha"
    else
      GCR_TAG=$(git rev-parse --short HEAD)
    fi
    echo "export GCR_TAG=${GCR_TAG}"  >> env_vars
    ./gradlew jib
  else
    echo "var DEV_PROJECT not defined for function gradlebuild"
    exit 1
  fi
}
