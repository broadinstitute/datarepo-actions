#!/bin/bash
function checknamespace {
  if [[ "${google_zone}" != "" ]] && [[ "${k8_cluster}" != "" ]] && [[ "${k8_namespaces}" != "" ]]; then
    gcloud container clusters get-credentials ${k8_cluster} --zone ${google_zone}
    for i in $(echo $k8_namespaces | sed "s/,/ /g")
    do
      if kubectl get secrets -n ${i} ${i}-inuse > /dev/null 2>&1; then
        printf "Namespace ${i} in use Skipping\n"
      else
        printf "Namespace ${i} not in use Deploying integration test to ${i}\n"
        kubectl create secret generic ${i}-inuse --from-literal=inuse=${i} -n ${i}
        tail=$(echo $i | awk -F- {'print $2'})
        echo "export IT_JADE_API_URL=https://jade-${tail}.datarepo-integration.broadinstitute.org" > env_var_druri
        echo "export NAMESPACEINUSE=${i}" > env_var_namespace
        return 0
      fi
    done
    sleep 120
    checknamespace
  else
    echo "required var not defined for function checknamespace"
    exit 1
  fi
}
