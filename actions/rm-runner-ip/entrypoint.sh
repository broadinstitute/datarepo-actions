#!/bin/sh

set -eu

# remove the runner IP from the list of authorized IPs
CUR_IPS=$(gcloud container clusters describe "${K8_CLUSTER}" --format json | \
    jq '[ .masterAuthorizedNetworksConfig.cidrBlocks[] | .cidrBlock ]')
RUNNER_IP=$(curl 'https://api.ipify.org/?format=text')
RESTORE_IPS=$(echo "${CUR_IPS}" | \
    jq -r --arg ip "${RUNNER_IP}" '[ .[] | select(startswith($ip) | not) ] | unique | join(",")')

# restore the original list of authorized IPs if they exist
gcloud container clusters update "${K8_CLUSTER}" \
    --enable-master-authorized-networks \
    --master-authorized-networks "${RESTORE_IPS}"

printf "Successfully removed %s from allowlist" "${RUNNER_IP}"
