#!/bin/sh

set -e
set -x

# config
GITHUB_REPO=${GITHUB_REPO:-jade-data-repo}
GITHUB_USER_EMAIL=${GITHUB_USER_EMAIL:-broadbot@broadinstitute.org}
GITHUB_USER_NAME=${GITHUB_USER_NAME:-broadbot}
COMMIT_MESSAGE=${COMMIT_MESSAGE:-commit merged via github action}
MERGE_BRANCH=${MERGE_BRANCH:-develop}
SWITCH_DIRECTORIES=${SWITCH_DIRECTORIES:-false}

if ${SWITCH_DIRECTORIES} ; then
  cd "${GITHUB_WORKSPACE}"/"${GITHUB_REPO}"
fi

git config --global user.email "${GITHUB_USER_EMAIL}"
git config --global user.name "${GITHUB_USER_NAME}"
git add .
git commit -m "${COMMIT_MESSAGE}"
git push origin "${MERGE_BRANCH}"

set +x
