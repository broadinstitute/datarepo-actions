#!/bin/bash

function gradlebuild {
  if [[ "${DEV_PROJECT}" != "" ]]; then
    unset JAVA_HOME
    export GOOGLE_APPLICATION_CREDENTIALS=gcpsa.json
    GCR_TAG=$(git rev-parse --short HEAD)
    echo "export GCR_TAG=${GCR_TAG}" > env_var_tag
    ./gradlew jib
  fi
}
