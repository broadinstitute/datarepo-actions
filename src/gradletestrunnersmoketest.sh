#!/bin/bash

gradletestrunnersmoketest () {
  cd ${GITHUB_WORKSPACE}/${workingDir}/datarepo-client

  echo "Building Data Repo client library"
  ../gradlew clean assemble  
  cd ${GITHUB_WORKSPACE}/${workingDir}/datarepo-clienttests
  export ORG_GRADLE_PROJECT_datarepoclientjar=$(ls ../datarepo-client/build/libs/*jar)
  echo "ORG_GRADLE_PROJECT_datarepoclientjar = ${ORG_GRADLE_PROJECT_datarepoclientjar}"

  echo "Running spotless and spotbugs"
  ./gradlew spotlessCheck
  ./gradlew spotbugsMain

  echo "Setting Test Runner environment variables"
  export TEST_RUNNER_SERVER_SPECIFICATION_FILE="${NAMESPACEINUSE}.json"
  export TEST_RUNNER_KEY_DIRECTORY_PATH="${GITHUB_WORKSPACE}"
  echo "TEST_RUNNER_SERVER_SPECIFICATION_FILE = ${TEST_RUNNER_SERVER_SPECIFICATION_FILE}"
  echo "TEST_RUNNER_KEY_DIRECTORY_PATH = ${TEST_RUNNER_KEY_DIRECTORY_PATH}"

  echo "Running test suite"
  ./gradlew runTest --args="suites/PRSmokeTests.json tmp/TestRunnerResults"

  echo "Collecting measurements"
  ./gradlew collectMeasurements --args="AllMeasurements.json tmp/TestRunnerResults"

  echo "Uploading results"
  ./gradlew uploadResults --args="BroadJadeDev.json tmp/TestRunnerResults"

  cd ${GITHUB_WORKSPACE}/${workingDir}
}
