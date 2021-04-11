#!/bin/bash
waitfordeployment () {
  eval $(cat env_vars)
  if [[ "${google_zone}" != "" ]] && [[ "${K8_CLUSTER}" != "" ]]; then
    # wait for deployment to happen
    echo "sleep 15 seconds to wait for ui pod to go down after helm deploy..."
    sleep 15
    if kubectl get deployments -n ${NAMESPACEINUSE} ${NAMESPACEINUSE}-jade-datarepo-ui -o jsonpath="{.status}" | grep unavailable; then
      sleep 10
      echo "ui pod unavailable waiting 10 seconds..."
      waitfordeployment
    else
      pod=$(kubectl get deployments -n ${NAMESPACEINUSE} ${NAMESPACEINUSE}-jade-datarepo-ui -o jsonpath="{..metadata.name}")
      echo "${pod} has been deployed and in ready state"
      #sleep 5 to be safe
      sleep 5
    fi
  else
    echo "required var not defined for function waitfordeployment"
    exit 1
  fi
}
