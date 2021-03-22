#!/bin/sh

set -eu

# determine whether repo is api or ui
case "${PWD}" in
    *-ui) GIT_WHICH_REPO=ui ;;
    *) GIT_WHICH_REPO=api ;;
esac

# get latest semantic version
REPO_TAG=$(git describe --tags "$(git rev-list --tags --max-count=1)")

cd datarepo-helm-definitions

# get current helm image tag version
HELM_DEV=$(find . -name devDeployment.yaml)
HELM_PROP="datarepo-${GIT_WHICH_REPO}.image.tag"
HELM_TAG=$(yq r "${HELM_DEV}" "${HELM_PROP}")

# replace the image tag if it doesn't match the semantic version
if [ "${REPO_TAG}" != "${HELM_TAG}" ]; then
    yq w -i "${HELM_DEV}" "${HELM_PROP}" "${REPO_TAG}"
    # configure git settings
    git config --global user.email "broadbot@broadinstitute.org"
    git config --global user.name "broadbot"
    git config pull.rebase false
    # commit changes to helm definitions
    git pull origin master
    git add "${HELM_DEV}"
    git commit -m "Dev Datarepo version update: ${REPO_TAG}"
    # push changes to master branch
    git push origin master
    git rev-parse HEAD
fi
