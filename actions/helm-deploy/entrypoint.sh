#!/bin/sh

set -e
set -x

if [ -f helmprerundone ]; then
  printf "Skipping helmprerun\n"
else
  helm plugin install https://github.com/thomastaylor312/helm-namespace
  helm repo add datarepo-helm https://broadinstitute.github.io/datarepo-helm
  helm repo update
  touch helmprerundone
fi

HELM_CREATE_SECRET_MANAGER_SECRET_VERSION=""
if [ -n "${INPUT_HELM_CREATE_SECRET_MANAGER_SECRET_VERSION}" ]; then
    export HELM_CREATE_SECRET_MANAGER_SECRET_VERSION="${INPUT_HELM_CREATE_SECRET_MANAGER_SECRET_VERSION}"
fi
HELM_DATAREPO_API_CHART_VERSION=""
if [ -n "${INPUT_HELM_DATAREPO_API_CHART_VERSION}" ]; then
    export HELM_DATAREPO_API_CHART_VERSION="${INPUT_HELM_DATAREPO_API_CHART_VERSION}"
fi
HELM_DATAREPO_UI_CHART_VERSION=""
if [ -n "${INPUT_HELM_DATAREPO_UI_CHART_VERSION}" ]; then
    export HELM_DATAREPO_UI_CHART_VERSION="${INPUT_HELM_DATAREPO_UI_CHART_VERSION}"
fi
HELM_OIDC_PROXY_CHART_VERSION=""
if [ -n "${INPUT_HELM_OIDC_PROXY_CHART_VERSION}" ]; then
    export HELM_OIDC_PROXY_CHART_VERSION="${INPUT_HELM_OIDC_PROXY_CHART_VERSION}"
fi
HELM_GCLOUD_SQLPROXY_CHART_VERSION=""
if [ -n "${INPUT_HELM_GCLOUD_SQLPROXY_CHART_VERSION}" ]; then
    export HELM_GCLOUD_SQLPROXY_CHART_VERSION="${INPUT_HELM_GCLOUD_SQLPROXY_CHART_VERSION}"
fi
HELM_IMAGETAG_UPDATE=""
if [ -n "${INPUT_HELM_IMAGETAG_UPDATE}" ]; then
    export HELM_IMAGETAG_UPDATE=${INPUT_HELM_IMAGETAG_UPDATE}
fi

# Delete the previous API deployment
RELEASE_NAME="${NAMESPACEINUSE}-jade"

if [ "${helm_imagetag_update}" = "api" ]; then
    helm delete --namespace "${NAMESPACEINUSE}" "${RELEASE_NAME}-datarepo-api"
fi

GCR_TAG=$(git rev-parse --short HEAD)

helm namespace upgrade "${RELEASE_NAME}-create-secret-manager-secret" datarepo-helm/create-secret-manager-secret --version="${HELM_CREATE_SECRET_MANAGER_SECRET_VERSION}" \
    --install --namespace "${NAMESPACEINUSE}" -f \
    "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/create-secret-manager-secret.yaml"

helm namespace upgrade "${RELEASE_NAME}-gcloud-sqlproxy" datarepo-helm/gcloud-sqlproxy --version="${helm_gcloud_sqlproxy_chart_version}" \
    --install --namespace "${NAMESPACEINUSE}" -f \
    "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/gcloud-sqlproxy.yaml"
sleep 3

if [ "${helm_imagetag_update}" = "api" ]; then
    helm namespace upgrade "${RELEASE_NAME}-datarepo-api" datarepo-helm/datarepo-api --version="${HELM_DATAREPO_API_CHART_VERSION}" \
        --install --namespace "${NAMESPACEINUSE}" -f \
        "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/datarepo-api.yaml" \
        --set "image.tag=${GCR_TAG}"
    sleep 3
else
    helm namespace upgrade "${RELEASE_NAME}-datarepo-api" datarepo-helm/datarepo-api --version="${HELM_DATAREPO_API_CHART_VERSION}" \
        --install --namespace "${NAMESPACEINUSE}" -f \
        "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/datarepo-api.yaml"
    sleep 3
fi

if [ "${helm_imagetag_update}" = "ui" ]; then
    helm namespace upgrade "${RELEASE_NAME}-datarepo-ui" datarepo-helm/datarepo-ui --version="${HELM_DATAREPO_UI_CHART_VERSION}" \
        --install --namespace "${NAMESPACEINUSE}" -f \
        "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/datarepo-ui.yaml" \
        --set "image.tag=${GCR_TAG}"
    sleep 3
else
    helm namespace upgrade "${RELEASE_NAME}-datarepo-ui" datarepo-helm/datarepo-ui --version="${HELM_DATAREPO_UI_CHART_VERSION}" \
        --install --namespace "${NAMESPACEINUSE}" -f \
        "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/datarepo-ui.yaml"
    sleep 3
fi

helm namespace upgrade "${RELEASE_NAME}-oidc-proxy" datarepo-helm/oidc-proxy --version="${helm_oidc_proxy_chart_version}" \
    --install --namespace "${NAMESPACEINUSE}" -f \
    "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/oidc-proxy.yaml"
sleep 3
