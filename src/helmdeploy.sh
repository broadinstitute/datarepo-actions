#!/bin/bash
helmdeploy () {
  eval $(cat env_vars)
  if [[ "${google_zone}" != "" ]] && [[ "${k8_cluster}" != "" ]] && [[ "${helm_imagetag_update}" != "" ]]; then
    helm namespace upgrade ${NAMESPACEINUSE}-secrets datarepo-helm/create-secret-manager-secret --version=${helm_secret_chart_version} \
      --install --namespace ${NAMESPACEINUSE} -f \
      "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/${NAMESPACEINUSE}Secrets.yaml"

    # Delete the previous API deployment
    helm delete --namespace ${NAMESPACEINUSE} ${NAMESPACEINUSE}-jade-datarepo-api

    release_name="${NAMESPACEINUSE}-jade"
    charts=("gcloud-sqlproxy" "datarepo-api" "datarepo-ui" "oidc-proxy")
    for i in "${charts[@]}"
    do
        helm namespace upgrade ${release_name}-${i} datarepo-helm/${i} --version=${helm_datarepo_chart_version} --install \
             --namespace ${NAMESPACEINUSE} -f \
             "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${NAMESPACEINUSE}/${i}.yaml" \
             --set "datarepo-${helm_imagetag_update}.image.tag=${GCR_TAG}"
        sleep 5
    done

  else
    echo "required var not defined for function helmdeploy"
    exit 1
  fi
}
