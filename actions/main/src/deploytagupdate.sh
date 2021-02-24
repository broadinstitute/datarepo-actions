#!/bin/bash

deploytagupdate () {
  eval $(cat env_vars)
  if [[ -n "${helm_env_prefix}" ]] && [[ -n "${helm_imagetag_update}" ]]; then
    export repo="gcr.io/${DEV_PROJECT}/jade-data-repo"
    for i in $(echo $helm_env_prefix | sed "s/,/ /g")
    do
      printf "New image tag to be deployed to dev ${GCR_TAG}\n"
      # check for image before deploy
      if [[ "${helm_imagetag_update}" == "api" ]]; then
        gcloud container images list-tags ${repo} --filter=${GCR_TAG}
        gcloud container images add-tag ${repo}:${GCR_TAG} \
          ${repo}:${GCR_TAG}-develop --quiet
      elif [[ "${helm_imagetag_update}" == "ui" ]]; then
        gcloud container images list-tags ${repo}-ui --filter=${GCR_TAG}
        gcloud container images add-tag ${repo}-ui:${GCR_TAG} \
          ${repo}-ui:${GCR_TAG}-develop --quiet
      else
        echo "no helm_env_prefix speficified"
        exit 1
      fi
      printf "Find and replace image with current develop commit\n"
      find . -name ${i}Deployment.yaml -type f -exec sh -c 'yq w -i $1 'datarepo-${helm_imagetag_update}.image.tag' $2-develop' sh {} ${GCR_TAG} ';'
      printf "Git add, commit and push\n"
      cd ${GITHUB_WORKSPACE}/${workingDir}/datarepo-helm-definitions
      git config --global user.email "robot@jade.team"
      git config --global user.name "imagetagbot"
      if [[ "${i}" == "dev" ]]; then
        git add dev/\*.yaml
      else
        git add integration/\*.yaml
      fi
      git commit -m "Updated images to latest jade-data-repo commit '${GCR_TAG}'"
      git push origin master
    done
  else
    echo "helm_env_prefix not defined for function deploytagupdate"
    exit 1
  fi
}
