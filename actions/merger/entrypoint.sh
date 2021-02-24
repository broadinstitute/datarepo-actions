#!/bin/sh

set -e

echo "HELLO FROM merger action"

echo "[INFO] git config email to broadbot@broadinstitute.org"
git config --global user.email broadbot@broadinstitute.org
echo "[INFO] git config name broadbot"
git config --global user.name broadbot
echo "[INFO] git add all"
cd ${GITHUB_WORKSPACE}/jade-data-repo
git add .github/workflows/alpha-promotion.yaml
echo "[INFO] commit w/ msg"
git commit -m "Datarepo chart version update"
echo "[INFO] git push"
git push origin develop
echo "[INFO] post push"
commit=$(git rev-parse HEAD)
echo "[INFO] commit: $commit"
