#!/bin/bash

uinpmbuild () {
  if [ -f env_vars ] && [[ -n "${IT_JADE_API_URL}" ]]; then
    echo "Getting GCR tags and IT_JADE_API_URL for npm build"
    eval $(cat env_vars)
  else
    echo "Skipping importing environment vars for npm build"
  fi
  if [[ -n "${google_project}" ]] && [ -f jade-dev-account.json ] && [ -f jade-dev-account.pem ]; then
    export PGHOST=$(ip route show default | awk '/default/ {print $3}')
    export GOOGLE_APPLICATION_CREDENTIALS=jade-dev-account.json
    export IT_JADE_PEM_FILE_NAME=jade-dev-account.pem
    export GOOGLE_SA_CERT=jade-dev-account.pem
    export GOOGLE_CLOUD_PROJECT=${google_project}
    export GCR_TAG=$(git rev-parse --short HEAD)
    echo "::set-env name=GCR_TAG::${GCR_TAG}"
    npm ci
    npm run-script build
  else
    echo "missing vars for function uinpmbuild"
    exit 1
  fi
}