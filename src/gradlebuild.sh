#!/bin/bash

gradlebuild () {
  if [[ "${DEV_PROJECT}" != "" ]]; then
    export GOOGLE_APPLICATION_CREDENTIALS=jade-dev-account.json
    GCR_TAG=$(git rev-parse --short HEAD)
    echo "export GCR_TAG=${GCR_TAG}"  >> env_vars
    ./gradlew jib
  else
    echo "var DEV_PROJECT not defined for function gradlebuild"
    exit 1
  fi
}
