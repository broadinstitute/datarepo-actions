#!/bin/sh

set -eu

# determine id of integration project
NAMESPACE_NUMBER=$(echo "${NAMESPACEINUSE}" | sed 's/integration-//g')
GOOGLE_INT_DATA_PROJECT="broad-jade-int-${NAMESPACE_NUMBER}-data"
echo "Cleaning up IAM policy for data project: ${GOOGLE_INT_DATA_PROJECT}"

# retrieve all IAM policies for data project
BINDINGS=$(gcloud projects get-iam-policy "${GOOGLE_INT_DATA_PROJECT}" --format=json)
# remove any policies that start with group:policy- or deleted:group:policy-
# group policies are created as a part of our test run and need to be cleared out
# to avoid hitting 250 IAM policy limit
OK_BINDINGS=$(echo "${BINDINGS}" | jq 'del(.bindings[] | select(.role=="roles/bigquery.jobUser") | .members[] | select(startswith("group:policy-") or startswith("deleted:group:policy-")))')

# replace the IAM policy, including only non-group policies/users
echo "${OK_BINDINGS}" | jq '.' > policy.json
gcloud projects set-iam-policy "${GOOGLE_INT_DATA_PROJECT}" policy.json
