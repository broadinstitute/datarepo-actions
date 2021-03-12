#!/bin/sh

set -eu

# determine whether image is api or ui
case "${GCR_DEV_URL}" in
    *-ui) GCR_WHICH_REPO=ui ;;
    *) GCR_WHICH_REPO=api ;;
esac

# set full path of container 
GCR_DEV_URL="${GCR_DEV_URL}:${GCR_IMG_VERSION}"
GCR_PUBLIC_URL="${GCR_PUBLIC_URL}:${GCR_IMG_VERSION}"

# cherry-pick image to public GCR
printf "Cherry picking v%s of %s\n  from \`%s\`\n    to \`%s\`\n" \
    "${GCR_IMG_VERSION}" "${GCR_WHICH_REPO}" "${GCR_DEV_URL}" "${GCR_PUBLIC_URL}"
gcloud container images add-tag --quiet "${GCR_DEV_URL}" "${GCR_PUBLIC_URL}"
