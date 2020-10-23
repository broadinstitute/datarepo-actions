#!/bin/bash
helmdeploy () {
  eval $(cat env_vars)
  if [[ "${google_zone}" != "" ]] && [[ "${K8_CLUSTER}" != "" ]] && [[ "${helm_imagetag_update}" != "" ]]; then
    helm namespace upgrade ${NAMESPACEINUSE}-create-secret-manager-secret datarepo-helm/create-secret-manager-secret --version=${helm_secret_chart_version} \
      --install --namespace ${NAMESPACEINUSE} -f \
      "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/create-secret-manager-secret.yaml"

    # Delete the previous API deployment
    helm delete --namespace ${NAMESPACEINUSE} ${NAMESPACEINUSE}-jade-datarepo-api

    release_name="${NAMESPACEINUSE}-jade"

    helm namespace upgrade ${release_name}-gcloud-sqlproxy datarepo-helm/gcloud-sqlproxy --version=${helm_gcloud_sqlproxy_chart_version} \
         --install --namespace ${NAMESPACEINUSE} -f \
         "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/gcloud-sqlproxy.yaml"
    sleep 3
    if [[ "${helm_imagetag_update}" == "api" ]]; then
      helm namespace upgrade ${release_name}-datarepo-api datarepo-helm/datarepo-api --version=${helm_datarepo_api_chart_version} \
           --install --namespace ${NAMESPACEINUSE} -f \
           "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/datarepo-api.yaml" \
           --set "image.tag=${GCR_TAG}"
      sleep 3
    else
      helm namespace upgrade ${release_name}-datarepo-api datarepo-helm/datarepo-api --version=${helm_datarepo_api_chart_version} \
           --install --namespace ${NAMESPACEINUSE} -f \
           "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/datarepo-api.yaml"
      sleep 3
    fi
    if [[ "${helm_imagetag_update}" == "ui" ]]; then
      helm namespace upgrade ${release_name}-datarepo-ui datarepo-helm/datarepo-ui --version=${helm_datarepo_ui_chart_version} \
           --install --namespace ${NAMESPACEINUSE} -f \
           "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/datarepo-ui.yaml" \
           --set "image.tag=${GCR_TAG}"
      sleep 3
    else
      helm namespace upgrade ${release_name}-datarepo-ui datarepo-helm/datarepo-ui --version=${helm_datarepo_ui_chart_version} \
           --install --namespace ${NAMESPACEINUSE} -f \
           "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/datarepo-ui.yaml"
      sleep 3
    fi
    helm namespace upgrade ${release_name}-oidc-proxy datarepo-helm/oidc-proxy --version=${helm_oidc_proxy_chart_version} \
         --install --namespace ${NAMESPACEINUSE} -f \
         "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/oidc-proxy.yaml"
    sleep 3

  else
    echo "required var not defined for function helmdeploy"
    exit 1
  fi
}
