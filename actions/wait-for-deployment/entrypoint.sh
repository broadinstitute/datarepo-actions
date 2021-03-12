#!/bin/sh

set -eu

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
