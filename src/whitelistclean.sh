#!/bin/bash

whitelistclean () {
  if [[ "${env.k8_cluster}" != "" ]]; then
    # export the original IP list so it can be restored during cleanup
    CUR_IPS=$(gcloud container clusters describe ${env.k8_cluster} --format json | \
      jq -r '[ .masterAuthorizedNetworksConfig.cidrBlocks[] | .cidrBlock ]')
    RUNNER_IP=$(curl 'https://api.ipify.org/?format=text' | xargs printf '[ "%s/32" ]')
    RUNNER_IP=$(echo ${RUNNER_IP}| jq -r '.[0]')
    RESTORE_IPS=$(printf '%s\n' $CUR_IPS | jq -r --arg RUNNER_IP "$RUNNER_IP" '. - [ $RUNNER_IP ] | unique | join(",")')
    # restore the original list of authorized IPs if they exist
    gcloud container clusters update ${env.k8_cluster} \
      --enable-master-authorized-networks \
      --master-authorized-networks ${RESTORE_IPS}
  else
    echo "required var not defined for function whitelistclean"
    exit 1
  fi
}
