#!/bin/bash

gradletestrunnersmoketest () {
  export TEST_RUNNER_SERVER_SPECIFICATION_FILE="${NAMESPACEINUSE}.json"
  export TEST_RUNNER_DELEGATOR_SA_FILE="github-action-k8-sa.json"
  export TEST_RUNNER_SA_FILE="github-action-k8-sa.json"
  echo "Building Data Repo client library"
  cd ${GITHUB_WORKSPACE}/${workingDir}
  ./gradlew clean assemble
  cd ${GITHUB_WORKSPACE}/${workingDir}/datarepo-clienttests
  export ORG_GRADLE_PROJECT_datarepoclientjar=$(find .. -type f -name "datarepo-client*.jar")
  echo "Running TestRunner suite"
  ./gradlew runTest --args="suites/PRSmokeTests.json tmp/TestRunnerResults"
  cd ${GITHUB_WORKSPACE}/${workingDir}
}
