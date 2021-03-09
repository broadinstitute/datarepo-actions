#!/bin/sh

set -eu

gcloud auth activate-service-account --key-file "${GOOGLE_APPLICATION_CREDENTIALS}"
gcloud config set project "${GOOGLE_CLOUD_PROJECT}"
gcloud config set compute/zone "${GOOGLE_REGION}"
gcloud auth configure-docker

if [ -n "${K8_CLUSTER}" ]; then
    gcloud container clusters get-credentials "${K8_CLUSTER}" --zone "${GOOGLE_REGION}"
fi
