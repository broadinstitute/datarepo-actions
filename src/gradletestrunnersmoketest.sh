#!/bin/bash

gradletestrunnersmoketest () {

  if [[ -n "${google_project}" ]] && [[ "${google_application_credentials}" != "" ]] && [ -f ${google_application_credentials} ]; then
    export GOOGLE_APPLICATION_CREDENTIALS=${google_application_credentials}
    export GOOGLE_CLOUD_PROJECT=${google_project}
    export GOOGLE_CLOUD_DATA_PROJECT=${google_data_project}
    export TEST_RUNNER_SERVER_SPECIFICATION_FILE="${NAMESPACEINUSE}.json"
    cd ${GITHUB_WORKSPACE}/${workingDir}/datarepo-client
    ../gradlew clean assemble  
    cd ${GITHUB_WORKSPACE}/${workingDir}/datarepo-clienttests
    export ORG_GRADLE_PROJECT_datarepoclientjar=$(ls ../datarepo-client/build/libs/*jar)
    ./gradlew runTest --args="suites/PRSmokeTests.json tmp/TestRunnerResults"
    cd ${GITHUB_WORKSPACE}/${workingDir}
  else
    echo "missing vars for function gradletestrunnersmoketest"
    exit 1
  fi
}
