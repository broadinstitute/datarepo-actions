#!/bin/bash

gradletestrunnersmoketest () {
  export TEST_RUNNER_SERVER_SPECIFICATION_FILE="${NAMESPACEINUSE}.json"
  export TEST_RUNNER_DELEGATOR_SA_FILE="github-action-k8-sa.json"
  cd ${GITHUB_WORKSPACE}/${workingDir}/datarepo-client
  echo "Building Data Repo client library"
  ../gradlew clean assemble  
  cd ${GITHUB_WORKSPACE}/${workingDir}/datarepo-clienttests
  export ORG_GRADLE_PROJECT_datarepoclientjar=$(ls ../datarepo-client/build/libs/*jar)
  echo "Running TestRunner suite"
  ./gradlew runTest --args="suites/PRSmokeTests.json tmp/TestRunnerResults"
  cd ${GITHUB_WORKSPACE}/${workingDir}
}
