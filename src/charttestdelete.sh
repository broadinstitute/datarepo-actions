#!/bin/bash

charttestdelete () {
  if [[ "${google_zone}" != "" ]] && [[ "${env.k8_cluster}" != "" ]] && [[ "${helm_charts_to_test}" != "" ]]; then
    for i in $(echo $helm_charts_to_test | sed "s/,/ /g")
    do
      helm delete "${release_name}-${i}" -n "${k8_namespaces}"
      sleep 5
    done
  else
    echo "required var not defined for function charttestdelete"
    exit 1
  fi
}
