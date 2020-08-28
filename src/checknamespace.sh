#!/bin/bash
checknamespace () {
  echo "checknamespace"
  echo "google_zone: ${google_zone}"
  echo "k8_cluster: ${k8_cluster}"
  echo "k8_namespaces: ${k8_namespaces}"
  if [[ "${google_zone}" != "" ]] && [[ "${k8_cluster}" != "" ]] && [[ "${k8_namespaces}" != "" ]]; then
    for i in $(echo $k8_namespaces | sed "s/,/ /g")
    do
      if kubectl get secrets -n ${i} ${i}-inuse > /dev/null 2>&1; then
        echo $(pwd)
        printf "Namespace ${i} in use Skipping\n"
      else
        printf "Namespace ${i} not in use Deploying integration test to ${i}\n"
        kubectl create secret generic ${i}-inuse --from-literal=inuse=${i} -n ${i}
        if [[ "$i" =~ "-" ]]; then
          tail=$(echo $i | awk -F- {'print $2'})
          echo "Stripping - from namespace for IT_JADE_API_URL"
        else
          tail=$i
          echo "using full namespace for IT_JADE_API_URL"
        fi
        echo "export IT_JADE_API_URL=https://jade-${tail}.datarepo-integration.broadinstitute.org" >> env_vars
        echo "export NAMESPACEINUSE=${i}" >> env_vars
        return 0
      fi
    done
    sleep 120
    checknamespace
  else
    echo "required var not defined for function checknamespace"
    exit 1
  fi
}
