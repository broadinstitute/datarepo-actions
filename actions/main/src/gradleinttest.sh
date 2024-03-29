#!/bin/bash

cleaniampolicy () {
  # determine id of integration project
  namespace_number=$(echo ${NAMESPACEINUSE} | sed 's/integration-//g')
  google_data_project="broad-jade-int-${namespace_number}-data"
  echo "Cleaning up IAM policy for data project: ${google_data_project}"

  # retrieve all IAM policies for data project
  BINDINGS=$(gcloud projects get-iam-policy ${google_data_project} --format=json)
  # remove any policies that start with group:policy- or deleted:group:policy-
  # group policies are created as a part of our test run and need to be cleared out
  # to avoid hitting 250 IAM policy limit
  OK_BINDINGS=$(echo ${BINDINGS} | jq 'del(.bindings[] | select(.role=="roles/bigquery.jobUser") | .members[] | select(startswith("group:policy-") or startswith("deleted:group:policy-")))')
  # replace the IAM policy, including only non-group policies/users
  echo ${OK_BINDINGS} | jq '.' > policy.json
  gcloud projects set-iam-policy ${google_data_project} policy.json
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

  if [[ "${test_filter}" == "" ]]; then
    echo "Running all tests"
    test_filter_cmd=""
  else
    echo "Running subset of tests: ${test_filter}"
    test_filter_cmd="--tests ${test_filter}"
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
    if [[ $test_to_run == check && -n $SONAR_TOKEN ]]; then
      echo "Sonar scan will run after the check action"
      export sonar_cmd="jacocoTestReport sonar"     
    fi
    pg_isready -h ${PGHOST} -p ${PGPORT}
    psql -U postgres -f ./db/create-data-repo-db
    # required for tests
    ./gradlew assemble
    echo "Running ${test_to_run}"
    ./gradlew -w ${test_to_run} ${test_filter_cmd} --scan ${sonar_cmd}
    
  else
    echo "missing vars for function gradleinttest"
    exit 1
  fi
}
