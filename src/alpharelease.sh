#!/bin/bash

alpharelease () {
  if [[ -n "${alpharelease}" ]] && [[ -n "${DEV_PROJECT}" ]]; then
    printf "Running alpharelease for tag ${alpharelease}\n"
    # source and run gradlebuild
    source ${scriptDir}/gradlebuild.sh
    gradlebuild "${DEV_PROJECT}" "${alpharelease}"
  else
    printf "alpha release not sucessful missing vars"
    exit 1
  fi
}
