#!/bin/bash
waitfordeployment () {
  eval $(cat env_vars)
  if [[ "${google_zone}" != "" ]] && [[ "${k8_cluster}" != "" ]]; then
    if kubectl get deployments -n ${NAMESPACEINUSE} ${NAMESPACEINUSE}-jade-datarepo-ui -o jsonpath="{.status}" | grep unavailable; then
      sleep 10
      waitfordeployment
    else
      pod=$(kubectl get deployments -n ${NAMESPACEINUSE} ${NAMESPACEINUSE}-jade-datarepo-ui -o jsonpath="{..metadata.name}")
      echo "${pod} has been deploy and in ready state"
    fi
  else
    echo "required var not defined for function waitfordeployment"
    exit 1
  fi
}
