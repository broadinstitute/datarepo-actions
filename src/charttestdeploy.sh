#!/bin/bash

charttestdeploy () {
  if [[ "${google_zone}" != "" ]] && [[ "${K8_CLUSTER}" != "" ]] && [[ "${helm_charts_to_test}" != "" ]]; then
    for i in $(echo $helm_charts_to_test | sed "s/,/ /g")
    do
      helm namespace upgrade ${release_name}-${i} charts/${i} --install --namespace ${k8_namespaces} -f \
      "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/master/integration/${k8_namespaces}/${i}.yaml"
      sleep 5
    done
  else
    echo "required var not defined for function charttestdeploy"
    exit 1
  fi
}
