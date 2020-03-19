#!/bin/bash

deploytagupdate () {
  eval $(cat env_vars)
  if [[ -n "${helm_env_prefix}" ]]; then
    for i in $(echo $helm_env_prefix | sed "s/,/ /g")
    do
      printf "New image tag to be deployed to dev ${GCR_TAG}\n"
      # check for image before deploy
      gcloud container images list-tags gcr.io/${DEV_PROJECT}/jade-data-repo --filter=${GCR_TAG}
      gcloud container images add-tag gcr.io/${DEV_PROJECT}/jade-data-repo:${GCR_TAG} \
        gcr.io/${DEV_PROJECT}/jade-data-repo:${GCR_TAG}-develop --quiet
      printf "Find and replace image with current develop commit\n"
      find . -name ${i}Deployment.yaml -type f -exec sh -c 'yq w -i $1 'datarepo-${i}.image.tag' $2' sh {} ${GCR_TAG} ';'
      printf "Git add, commit and push\n"
      cd datarepo-helm-definitions
      git config --global user.email "robot@jade.team"
      git config --global user.name "imagetagbot"
      git add dev/dev/devDeployment.yaml
      git commit -m "Updated dev image to latest jade-data-repo commit `${GCR_TAG}`"
      git push origin master
    done
  else
    echo "helm_env_prefix not defined for function deploytagupdate"
    exit 1
  fi
}
