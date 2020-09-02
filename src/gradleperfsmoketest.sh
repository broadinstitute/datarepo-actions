#!/bin/bash

gradleperfsmoketest () {

  if [[ -n "${google_project}" ]] && [[ "${google_application_credentials}" != "" ]] && [ -f ${google_application_credentials} ]; then
    #export PGHOST=$(ip route show default | awk '/default/ {print $3}')
    #export DB_DATAREPO_URI="jdbc:postgresql://${PGHOST}:5432/datarepo"
    #export DB_STAIRWAY_URI="jdbc:postgresql://${PGHOST}:5432/stairway"
    export GOOGLE_APPLICATION_CREDENTIALS=${google_application_credentials}
    #export IT_JADE_PEM_FILE_NAME=jade-dev-account.pem
    #export GOOGLE_SA_CERT=${google_application_credentials_pem}
    export GOOGLE_CLOUD_PROJECT=${google_project}
    export GOOGLE_CLOUD_DATA_PROJECT=${google_data_project}

    cd ${GITHUB_WORKSPACE}/${workingDir}/datarepo-client
    ../gradlew clean assemble
    cd ${GITHUB_WORKSPACE}/${workingDir}
    export ORG_GRADLE_PROJECT_datarepoclientjar=.$(ls ./datarepo-client/build/libs/*jar)
    export TEST_RUNNER_SERVER_SPECIFICATION_FILE="${NAMESPACEINUSE}.json"
    cd ${GITHUB_WORKSPACE}/${workingDir}/datarepo-clienttests      
    ./gradlew runTest --args="suites/PRSmokeTests.json tmp/TestRunnerResults"
    cd ${GITHUB_WORKSPACE}/${workingDir}
  else
    echo "missing vars for function gradleinttest"
    exit 1
  fi
}
