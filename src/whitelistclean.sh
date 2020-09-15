#!/bin/bash

whitelistclean () {
  if [[ "${K8_CLUSTER}" != "" ]]; then
    # export the original IP list so it can be restored during cleanup
    CUR_IPS=$(gcloud container clusters describe ${K8_CLUSTER} --format json | \
      jq -r '[ .masterAuthorizedNetworksConfig.cidrBlocks[] | .cidrBlock ]')
    RUNNER_IP=$(curl 'https://api.ipify.org/?format=text' | xargs printf '[ "%s/32" ]')
    RUNNER_IP=$(echo ${RUNNER_IP}| jq -r '.[0]')
    RESTORE_IPS=$(printf '%s\n' $CUR_IPS | jq -r --arg RUNNER_IP "$RUNNER_IP" '. - [ $RUNNER_IP ] | unique | join(",")')
    # restore the original list of authorized IPs if they exist
    gcloud container clusters update ${K8_CLUSTER} \
      --enable-master-authorized-networks \
      --master-authorized-networks ${RESTORE_IPS}
  else
    echo "required var not defined for function whitelistclean"
    exit 1
  fi
}
