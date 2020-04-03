#!/bin/bash

charttestdeploy () {
  if [[ "${google_zone}" != "" ]] && [[ "${k8_cluster}" != "" ]] && [[ "${helm_charts_to_test}" != "" ]]; then
    for i in $(echo $helm_charts_to_test | sed "s/,/ /g")
    do
      helm namespace upgrade ${relase_name}-${i} charts/${i} --install --namespace ${charttestnamespace} -f \
      "https://raw.githubusercontent.com/broadinstitute/datarepo-helm-definitions/ms-charttester/integration/${charttestnamespace}/${i}.yaml"
      sleep 5
    done
  else
    echo "required var not defined for function charttestdeploy"
    exit 1
  fi
}
