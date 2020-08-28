#!/bin/bash

gradlebuild () {
  if [[ -n "$1" ]]; then
    export DEV_PROJECT=$1
  fi
  if [[ -n "$2" ]]; then
    export alpharelease=$2
  fi
  if [[ "${DEV_PROJECT}" != "" ]] && [[ "${google_application_credentials}" != "" ]]; then
    export GOOGLE_APPLICATION_CREDENTIALS=${google_application_credentials}
    if [[ -n "${alpharelease}" ]]; then
      printf "running gradle with alpha tag ${alpharelease}"
      export GCR_TAG="${alpharelease}"
    else
      export GCR_TAG=$(git rev-parse --short HEAD)
      printf "Using tag from local dir $GCR_TAG"
    fi
    echo "export GCR_TAG=${GCR_TAG}"  >> env_vars
    ./gradlew jib
  else
    echo "required var not defined for function gradlebuild"
    exit 1
  fi
}
