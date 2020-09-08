#!/bin/bash

whitelist () {
  if [[ "${K8_CLUSTER}" != "" ]]; then
    CUR_IPS=$(gcloud container clusters describe ${K8_CLUSTER} --format json | \
      jq -r '[.masterAuthorizedNetworksConfig.cidrBlocks[] | .cidrBlock]')
      RUNNER_IP=$(curl 'https://api.ipify.org/?format=text' | xargs printf '[ "%s/32" ]')
      NEW_IPS=$(printf '%s\n' $CUR_IPS $RUNNER_IP | jq -s -r 'add | unique | join(",")')
    for i in {1..5}
    do
      if gcloud container clusters update ${K8_CLUSTER} \
        --enable-master-authorized-networks \
        --master-authorized-networks ${NEW_IPS}; then
          echo "successful whitelist"
          break
      else
        echo "failed to whitelist"
        sleep 15
        if [ i == 5 ]; then
          echo "FAILURE TO WHITELIST"
          exit 1
        fi
      fi
    done
  else
    echo "Required var not defined for function whitelist"
    exit 1
  fi
}
