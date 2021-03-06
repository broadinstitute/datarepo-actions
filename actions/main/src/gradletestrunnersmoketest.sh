#!/bin/bash

gradletestrunnersmoketest () {
  echo "Building Data Repo client library"
  cd ${GITHUB_WORKSPACE}/${workingDir}
  ENABLE_SUBPROJECT_TASKS=1 ./gradlew :datarepo-client:clean :datarepo-client:assemble
  cd ${GITHUB_WORKSPACE}/${workingDir}/datarepo-clienttests

  echo "Setting Test Runner environment variables"
  export ORG_GRADLE_PROJECT_datarepoclientjar=$(find .. -type f -name "datarepo-client*.jar")
  export TEST_RUNNER_SERVER_SPECIFICATION_FILE="${NAMESPACEINUSE}.json"
  export TEST_RUNNER_SA_KEY_DIRECTORY_PATH="${GITHUB_WORKSPACE}"
  echo "ORG_GRADLE_PROJECT_datarepoclientjar = ${ORG_GRADLE_PROJECT_datarepoclientjar}"
  echo "TEST_RUNNER_SERVER_SPECIFICATION_FILE = ${TEST_RUNNER_SERVER_SPECIFICATION_FILE}"
  echo "TEST_RUNNER_SA_KEY_DIRECTORY_PATH = ${TEST_RUNNER_SA_KEY_DIRECTORY_PATH}"
  
  echo "Running spotless and spotbugs"
  ./gradlew spotlessCheck
  ./gradlew spotbugsMain

  local outputDir="/tmp/TestRunnerResults"
  echo "Output directory set to: $outputDir"
  
  echo "Running tests"
  ./gradlew runTest --args="suites/PRSmokeTests.json $outputDir" ||
    (echo "Running tests FAILED" &&
    ./gradlew uploadResults --args="BroadJadeDev.json $outputDir" &&
    return 1)
  echo "Running test suite SUCCEEDED"

  cd ${GITHUB_WORKSPACE}/${workingDir}
}
