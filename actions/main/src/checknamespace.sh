#!/bin/bash
checknamespace () {
  if [[ "${google_zone}" != "" ]] && [[ "${K8_CLUSTER}" != "" ]] && [[ "${k8_namespaces}" != "" ]]; then
    for i in $(echo $k8_namespaces | sed "s/,/ /g")
    do
      if kubectl get secrets -n ${i} ${i}-inuse > /dev/null 2>&1; then
        printf "Namespace ${i} in use Skipping\n"
      else
        printf "Namespace ${i} not in use Deploying integration test to ${i}\n"
        kubectl create secret generic ${i}-inuse --from-literal=inuse=${i} -n ${i}
        TAIL=$(echo ${i} | sed -r 's/.*\-([0-9]+)/\1/')
        API_URL="https://jade-${TAIL}.datarepo-integration.broadinstitute.org"
        echo "export IT_JADE_API_URL=${API_URL}" >> env_vars
        echo "export NAMESPACEINUSE=${i}" >> env_vars
        #Needed for new containerized actions
        echo "IT_JADE_API_URL=${API_URL}" >> "$GITHUB_ENV"
        echo "NAMESPACEINUSE=${i}" >> "$GITHUB_ENV"
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
