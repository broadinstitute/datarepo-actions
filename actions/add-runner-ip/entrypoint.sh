#!/bin/sh

set -eu

# add current runner IP to the list of authorized IPs
CUR_IPS=$(gcloud container clusters describe "${K8_CLUSTER}" --format json | \
    jq '[.masterAuthorizedNetworksConfig.cidrBlocks[] | .cidrBlock]')
RUNNER_IP=$(curl 'https://api.ipify.org/?format=text')
NEW_IPS=$(echo "${CUR_IPS}" | jq -r --arg ip "${RUNNER_IP}" '[ .[] , $ip + "/32" ] | join(",")')

i=1
while true; do
    if [ "$i" = 5 ]; then
        echo "Failed to add runner to allowlist -- Terminating"
        exit 1
    fi
    if gcloud container clusters update "${K8_CLUSTER}" \
            --enable-master-authorized-networks \
            --master-authorized-networks "${NEW_IPS}"; then
        echo "Successfully added ${RUNNER_IP} to allowlist"
        break
    else
        echo "Failed to add runner to allowlist -- Retrying"
        sleep 15
    fi
    i=$((i + 1))
done
