#!/bin/bash
waitfordeployment () {
  eval $(cat env_vars)
  if [[ "${google_zone}" != "" ]] && [[ "${K8_CLUSTER}" != "" ]]; then
    # wait for deployment to happen
    echo "sleep 15 seconds to wait for ui pod to go down after helm deploy..."
    sleep 15
    #----------- [API Deployment Only] Wait for Integration API Pod to spin back up with correct version --------------
    if [[ ${DEPLOYMENT_TYPE} == 'api' ]]; then
      echo "Checking ${IT_JADE_API_URL}"
      CURRENT_GITHASH=$(curl -s -X GET "${IT_JADE_API_URL}/configuration" -H "accept: application/json" | jq -R '. | try fromjson catch {"gitHash":"failedToContact"}' | jq -r '.gitHash')
      if [[ "$DESIRED_GITHASH" == "$CURRENT_GITHASH" ]]; then
        echo "${IT_JADE_API_URL} successfully running on new version: $DESIRED_GITHASH"
      else
        echo "Waiting 10 seconds for $DESIRED_GITHASH to equal $CURRENT_GITHASH"
        sleep 10
        waitfordeployment
        break
      fi
    fi
    #----------- [API or UI Deployment] Wait for UI Pod to spin back up --------------
    if kubectl get deployments -n ${NAMESPACEINUSE} ${NAMESPACEINUSE}-jade-datarepo-ui -o jsonpath="{.status}" | grep unavailable; then
      echo "ui pod unavailable waiting 10 seconds..."
      sleep 10
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
