#!/bin/bash

function checknamespaceclean {
  if [[ "${google_zone}" != "" ]] && [[ "${k8_cluster}" != "" ]]; then
    gcloud container clusters get-credentials ${k8_cluster} --zone ${google_zone}
    eval $(cat env_var_namespace)
    kubectl delete secret -n ${NAMESPACEINUSE} "${NAMESPACEINUSE}-inuse"
  fi
}
