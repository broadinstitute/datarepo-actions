#!/bin/sh

set -e

# config
GITHUB_REPO=${GITHUB_REPO:-jade-data-repo}
GITHUB_USER_EMAIL=${GITHUB_USER_EMAIL:-broadbot@broadinstitute.org}
GITHUB_USER_NAME=${GITHUB_USER_NAME:-broadbot}
GITHUB_WORKSPACE=${GITHUB_WORKSPACE}
COMMIT_MESSAGE="${COMMIT_MESSAGE:-"commit merged via github action"}"
MERGE_BRANCH=${MERGE_BRANCH:-develop}
SWITCH_DIRECTORIES=${SWITCH_DIRECTORIES:-"false"}

if ${SWITCH_DIRECTORIES} ; then
  echo "[INFO] change directory to ${GITHUB_WORKSPACE}/${GITHUB_REPO}"
  cd "${GITHUB_WORKSPACE}"/"${GITHUB_REPO}"
fi

echo "[INFO] git config email to ${GITHUB_USER_EMAIL}"
git config --global user.email "${GITHUB_USER_EMAIL}"
echo "[INFO] git config name ${GITHUB_USER_NAME}"
git config --global user.name "${GITHUB_USER_NAME}"
echo "[INFO] git add all"
git add .
echo "[INFO] commit w/ msg"
git commit -m "${COMMIT_MESSAGE}"
echo "[INFO] Show ref"
git show-ref
echo "[INFO] git push ${MERGE_BRANCH}"
git push origin "${MERGE_BRANCH}"
echo "[INFO] post push"
commit=$(git rev-parse HEAD)
echo "[INFO] commit: $commit"
