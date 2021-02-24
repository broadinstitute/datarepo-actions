#!/bin/sh

set -e

# config
github_repo=${GITHUB_REPO:-jade-data-repo}
github_user_email=${GITHUB_USER_EMAIL:-broadbot@broadinstitute.org}
github_user_name=${GITHUB_USER_NAME:-broadbot}
github_workspace=${GITHUB_WORKSPACE}
commit_msg="${COMMIT_MESSAGE:-"commit merged via github action"}"
merge_branch=${MERGE_BRANCH:-develop}
switch_directories=${SWITCH_DIRECTORIES:-"false"}

if ${switch_directories}
then
echo "[INFO] change directory to ${github_workspace}/${github_repo}"
cd ${github_workspace}/${github_repo}
fi

echo "[INFO] git config email to ${github_user_email}"
git config --global user.email ${github_user_email}
echo "[INFO] git config name ${github_user_name}"
git config --global user.name ${github_user_name}
echo "[INFO] git add all"
git add .
echo "[INFO] commit w/ msg"
git commit -m "${commit_msg}"
echo "[INFO] Show ref"
git show-ref
echo "[INFO] git push ${merge_branch}"
git push origin ${merge_branch}
echo "[INFO] post push"
commit=$(git rev-parse HEAD)
echo "[INFO] commit: $commit"
