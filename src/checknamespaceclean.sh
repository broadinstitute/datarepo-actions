#!/bin/bash

checknamespaceclean () {
  eval $(cat env_vars)
  if [[ "${google_zone}" != "" ]] && [[ $k8_cluster != "" ]]; then
    kubectl delete secret -n ${NAMESPACEINUSE} "${NAMESPACEINUSE}-inuse"
  else
    echo "vars for checknamespaceclean not defined"
    exit 1
  fi
}
