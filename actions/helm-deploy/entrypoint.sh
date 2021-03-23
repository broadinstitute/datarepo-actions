#!/bin/sh

set -eux

if [ -f helmprerundone ]; then
  printf "Skipping helmprerun\n"
else
  helm plugin install https://github.com/thomastaylor312/helm-namespace
  helm repo add datarepo-helm https://broadinstitute.github.io/datarepo-helm
  helm repo update
  touch helmprerundone
fi

helm_create_secret_manager_secret_version=""
if [ -n "${INPUT_HELM_CREATE_SECRET_MANAGER_SECRET_VERSION}" ]; then
    export helm_create_secret_manager_secret_version="${INPUT_HELM_CREATE_SECRET_MANAGER_SECRET_VERSION}"
    echo "1 - helm_create_secret_manager_secret_version: ${helm_create_secret_manager_secret_version}"
fi
helm_datarepo_api_chart_version=""
if [ -n "${INPUT_HELM_DATAREPO_API_CHART_VERSION}" ]; then
    export helm_datarepo_api_chart_version="${INPUT_HELM_DATAREPO_API_CHART_VERSION}"
    echo "2 - helm_datarepo_api_chart_version: ${helm_datarepo_api_chart_version}"
fi
helm_datarepo_ui_chart_version=""
if [ -n "${INPUT_HELM_DATAREPO_UI_CHART_VERSION}" ]; then
    export helm_datarepo_ui_chart_version="${INPUT_HELM_DATAREPO_UI_CHART_VERSION}"
    echo "3 - helm_datarepo_ui_chart_version: ${helm_datarepo_ui_chart_version}"
fi
helm_oidc_proxy_chart_version=""
if [ -n "${INPUT_HELM_OIDC_PROXY_CHART_VERSION}" ]; then
    export helm_oidc_proxy_chart_version="${INPUT_HELM_OIDC_PROXY_CHART_VERSION}"
    echo "4 - helm_oidc_proxy_chart_version: ${helm_oidc_proxy_chart_version}"
fi
helm_gcloud_sqlproxy_chart_version=""
if [ -n "${INPUT_HELM_GCLOUD_SQLPROXY_CHART_VERSION}" ]; then
    export helm_gcloud_sqlproxy_chart_version="${INPUT_HELM_GCLOUD_SQLPROXY_CHART_VERSION}"
    echo "5 - helm_gcloud_sqlproxy_chart_version: ${helm_gcloud_sqlproxy_chart_version}"
fi
helm_imagetag_update=""
if [ -n "${INPUT_HELM_IMAGETAG_UPDATE}" ]; then
    export helm_imagetag_update=${INPUT_HELM_IMAGETAG_UPDATE}
    echo "6 - helm_imagetag_update: ${helm_imagetag_update}"
fi

echo "NAMESPACEINUSE: ${NAMESPACEINUSE}"

# Delete the previous API deployment
release_name="${NAMESPACEINUSE}-jade"

if [ "${helm_imagetag_update}" = "api" ]; then
    helm delete --namespace "${NAMESPACEINUSE}" "${release_name}-datarepo-api"
fi

GCR_TAG=$(git rev-parse --short HEAD)

helm namespace upgrade "${release_name}-create-secret-manager-secret" datarepo-helm/create-secret-manager-secret --version="${helm_create_secret_manager_secret_version}" \
    --install --namespace "${NAMESPACEINUSE}" -f \
    "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/create-secret-manager-secret.yaml"

helm namespace upgrade "${release_name}-gcloud-sqlproxy" datarepo-helm/gcloud-sqlproxy --version="${helm_gcloud_sqlproxy_chart_version}" \
    --install --namespace "${NAMESPACEINUSE}" -f \
    "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/gcloud-sqlproxy.yaml"
sleep 3

if [ "${helm_imagetag_update}" = "api" ]; then
    helm namespace upgrade "${release_name}-datarepo-api" datarepo-helm/datarepo-api --version="${helm_datarepo_api_chart_version}" \
        --install --namespace "${NAMESPACEINUSE}" -f \
        "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/datarepo-api.yaml" \
        --set "image.tag=${GCR_TAG}"
    sleep 3
else
    helm namespace upgrade "${release_name}-datarepo-api" datarepo-helm/datarepo-api --version="${helm_datarepo_api_chart_version}" \
        --install --namespace "${NAMESPACEINUSE}" -f \
        "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/datarepo-api.yaml"
    sleep 3
fi

if [ "${helm_imagetag_update}" = "ui" ]; then
    helm namespace upgrade "${release_name}-datarepo-ui" datarepo-helm/datarepo-ui --version="${helm_datarepo_ui_chart_version}" \
        --install --namespace "${NAMESPACEINUSE}" -f \
        "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/datarepo-ui.yaml" \
        --set "image.tag=${GCR_TAG}"
    sleep 3
else
    helm namespace upgrade "${release_name}-datarepo-ui" datarepo-helm/datarepo-ui --version="${helm_datarepo_ui_chart_version}" \
        --install --namespace "${NAMESPACEINUSE}" -f \
        "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/datarepo-ui.yaml"
    sleep 3
fi

helm namespace upgrade "${release_name}-oidc-proxy" datarepo-helm/oidc-proxy --version="${helm_oidc_proxy_chart_version}" \
    --install --namespace "${NAMESPACEINUSE}" -f \
    "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/oidc-proxy.yaml"
sleep 3
