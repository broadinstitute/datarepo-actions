#!/bin/bash
function helmdeploy {
  if [[ "${google_zone}" != "" ]] && [[ "${k8_cluster}" != "" ]]; then
    eval $(cat env_var_namespace)
    eval $(cat env_var_tag)
    helm plugin install https://github.com/thomastaylor312/helm-namespace
    helm repo add datarepo-helm https://broadinstitute.github.io/datarepo-helm
    helm repo update
    helm namespace upgrade ${NAMESPACEINUSE}-secrets datarepo-helm/create-secret-manager-secret --version=${helm_secret_chart_version} \
      --install --namespace ${NAMESPACEINUSE} -f \
      "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/${NAMESPACEINUSE}Secrets.yaml"
    helm namespace upgrade ${NAMESPACEINUSE}-jade datarepo-helm/datarepo --version=${helm_datarepo_chart_version} --install \
      --namespace ${NAMESPACEINUSE} -f \
      "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/${NAMESPACEINUSE}Deployment.yaml" \
      --set "datarepo-api.image.tag=${GCR_TAG}"
  else
    echo "required var not defined for function helmdeploy"
    exit 1
  fi
}
