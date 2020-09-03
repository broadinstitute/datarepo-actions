#!/bin/bash

gradletestrunnersmoketest () {

  if [[ -n "${google_project}" ]] && [[ "${GOOGLE_APPLICATION_CREDENTIALS}" != "" ]] && [ -f ${GOOGLE_APPLICATION_CREDENTIALS} ]; then
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
