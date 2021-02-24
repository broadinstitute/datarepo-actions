#!/bin/bash

chartversion () {
  chart=$(yq read datarepo-helm/charts/datarepo/Chart.yaml version)
  yq w -i jade-data-repo/.github/workflows/alpha-promotion.yaml env.chartVersion $chart

  echo "[INFO] cd to jade-data-repo"
  cd ${GITHUB_WORKSPACE}/jade-data-repo
  echo "[INFO] git config email to broadbot@broadinstitute.org"
  git config --global user.email broadbot@broadinstitute.org
  echo "[INFO] git config name broadbot"
  git config --global user.name broadbot
  echo "[INFO] git add all"
  git add jade-data-repo/.github/workflows/alpha-promotion.yaml
  echo "[INFO] commit w/ msg: $COMMIT_MESSAGE"
  git commit --allow-empty -m "Datarepo chart version update: ${{ steps.chartversion.outputs.version }}"
  echo "[INFO] git push $DESTINATION_BRANCH"
  git push origin develop
  echo "[INFO] post push"
  commit=$(git rev-parse HEAD)
  echo "[INFO] commit: $commit"
}

