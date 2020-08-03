#!/bin/bash

gradlebuild () {
  if [[ -n "$1" ]]; then
    export DEV_PROJECT=$1
  fi
  if [[ -n "$2" ]]; then
    export alpharelease=$2
  fi
  if [[ "${DEV_PROJECT}" != "" ]]; then
    export GOOGLE_APPLICATION_CREDENTIALS=jade-dev-account.json
    if [[ -n "${alpharelease}" ]]; then
      printf "running gradle with alpha tag ${alpharelease}"
      export GCR_TAG="${alpharelease}-alpha"
    else
      export GCR_TAG=$(git rev-parse --short HEAD)
      printf "Using tag from local dir $GCR_TAG"
    fi
    echo "export GCR_TAG=${GCR_TAG}"  >> env_vars
    ./gradlew jib
  else
    echo "var DEV_PROJECT not defined for function gradlebuild"
    exit 1
  fi
}
