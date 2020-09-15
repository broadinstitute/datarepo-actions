#!/bin/bash

cleaniampolicy () {
  # determine id of integration project
  namespace_number=$(echo ${NAMESPACEINUSE} | sed 's/integration-//g')
  google_data_project="broad-jade-int-${namespace_number}-data"
  echo "Cleaning up IAM policy for data project: ${google_data_project}"

  # get the policy bindings for the project
  bindings=$(gcloud projects get-iam-policy ${google_data_project} --format=json)

  # get the members of the BigQuery Job User role
  members=$(echo $bindings | jq '.bindings[] | if .role == "roles/bigquery.jobUser" then .members else empty end')

  # Loop through the members that start with "group:policy-" That is the signature of a SAM group. And I hope nothing else important!
  # Remove the members one by one - this is noisy, but leaving it that way for now so we see the results in the log
  for row in $(echo $members | jq -r '.[] | select(startswith("group:policy-"))'); do
    if gcloud projects remove-iam-policy-binding ${google_data_project} --member=$row --role=roles/bigquery.jobUser; then
      echo "Successfully removed member: ${row}"
    else
      echo "Failed to remove member: ${row}"
    fi
  done
}

gradleinttest () {
  if [ -f env_vars ] && [[ -n "${IT_JADE_API_URL}" ]] && [[ "${test_to_run}" == "testIntegration" ]]; then
    echo "Getting GCR tags and IT_JADE_API_URL for integration test"
    eval $(cat env_vars)
  else
    echo "Skipping importing environment vars for gradleinttest"
  fi

  # hardcode data project for connected tests
  if [[ "${test_to_run}" == "testConnected" ]]; then
    google_data_project="broad-jade-integration-data"
    echo "Running ${test_to_run} test with data project: ${google_data_project}"
  else
    google_data_project=""
    echo "Running ${test_to_run} test with data project env var unset: ${google_data_project}"
  fi

  if [[ -n "${google_project}" ]] && [ -f ${GOOGLE_APPLICATION_CREDENTIALS} ] && [ -f ${GOOGLE_SA_CERT} ] && [[ "${test_to_run}" != "" ]]; then
    export PGHOST=$(ip route show default | awk '/default/ {print $3}')
    export DB_DATAREPO_URI="jdbc:postgresql://${PGHOST}:5432/datarepo"
    export DB_STAIRWAY_URI="jdbc:postgresql://${PGHOST}:5432/stairway"
    export GOOGLE_CLOUD_PROJECT=${google_project}
    export GOOGLE_CLOUD_DATA_PROJECT=${google_data_project}
    if [[ "${test_to_run}" == "testIntegration" ]]; then
      echo "Running integration tests against ${IT_JADE_API_URL}"
      cleaniampolicy
    fi
    pg_isready -h ${PGHOST} -p ${PGPORT}
    psql -U postgres -f ./db/create-data-repo-db
    # required for tests
    ./gradlew assemble
    ./gradlew check --scan
    ./gradlew ${test_to_run} --scan
  else
    echo "missing vars for function gradleinttest"
    exit 1
  fi
}
