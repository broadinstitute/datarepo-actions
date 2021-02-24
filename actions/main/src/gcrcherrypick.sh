#!/bin/sh

#GCR_WHICH_REPO=api
#GCR_IMG_VERSION=1.3.0

GCR_DEV_URL="gcr.io/broad-jade-dev/jade-data-repo"
GCR_PRD_URL="gcr.io/terra-datarepo-production/jade-data-repo"

cherry_pick_msg() {
    printf 'Cherry picking v%s of %s\n  from `%s`\n    to `%s`\n' "$1" "$2" "$3" "$4"
}

add_ui_url() {
    GCR_DEV_URL="${GCR_DEV_URL}-ui"
    GCR_PRD_URL="${GCR_PRD_URL}-ui"
}

add_version_url() {
    GCR_DEV_URL="${GCR_DEV_URL}:${GCR_IMG_VERSION}"
    GCR_PRD_URL="${GCR_PRD_URL}:${GCR_IMG_VERSION}"
}

gcrcherrypick() {
    case ${GCR_WHICH_REPO} in
        api)
            add_version_url ;;
        ui)
            add_ui_url ; add_version_url ;;
        *)
            echo '${GCR_WHICH_REPO} must be one of `api` or `ui`'; exit 1 ;;
    esac

    if [ -z "${GCR_IMG_VERSION}" ] ; then
        echo '${GCR_IMG_VERSION} must be defined'; exit 1
    fi

    cherry_pick_msg "${GCR_IMG_VERSION}" "${GCR_WHICH_REPO}" "${GCR_DEV_URL}" "${GCR_PRD_URL}"

    gcloud container images add-tag --quiet "${GCR_DEV_URL}" "${GCR_PRD_URL}"
}
