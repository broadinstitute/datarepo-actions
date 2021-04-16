#!/bin/sh

set -eu

# [API Deployment Only] Wait for Integration API Pod to spin back up with correct version
if [ "${DEPLOYMENT_TYPE}" = "api" ]; then
    while true; do
        echo "Checking ${API_URL}"
        CURRENT_GITHASH=$(curl -s -X GET "${API_URL}/configuration" -H "accept: application/json" | sed -r 's/.*"gitHash":"([a-f0-9]+)".*/\1/')
        if [ "${DESIRED_GITHASH}" = "${CURRENT_GITHASH}" ]; then
            echo "${API_URL} successfully running on new version: ${DESIRED_GITHASH}"
            break
        else
            echo "Waiting 10 seconds for ${DESIRED_GITHASH} to equal ${CURRENT_GITHASH}"
            sleep 10
        fi
    done
fi

# [API or UI Deployment] Wait for UI Pod to spin back up
while true; do
    if kubectl get deployments -n "${NAMESPACEINUSE}" "${NAMESPACEINUSE}-jade-datarepo-ui" -o jsonpath="{.status}" | grep unavailable; then
        echo "UI pod in ${NAMESPACEINUSE} unavailable -- Retrying"
        sleep 10
    else
        K8_POD=$(kubectl get deployments -n "${NAMESPACEINUSE}" "${NAMESPACEINUSE}-jade-datarepo-ui" -o jsonpath="{..metadata.name}")
        sleep 5
        echo "${K8_POD} has been deployed and is in ready state"
        break
    fi
done
