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

  outputDir="tmp/TestRunnerResults"

  echo "Running test suite"
  runTestOutput=$(./gradlew runTest --args="suites/PRSmokeTests.json $outputDir" 2>&1)
  runTestExitCode=$?
  echo "$runTestOutput"
  if [ $runTestExitCode -eq 1 ]; then
    echo "Running test suite failed, Uploading results"
    ./gradlew uploadResults --args="BroadJadeDev.json $outputDir"
    exit $runTestExitCode
  fi

  echo "Collecting measurements"
  collectMeasurementsOutput=$(./gradlew collectMeasurements --args="PRSmokeTests.json $outputDir" 2>&1)
  collectMeasurementsExitCode=$?
  echo "$collectMeasurementsOutput"
  if  [ $collectMeasurementsExitCode -eq 1 ]; then
    echo "Collecting measurements failed, Uploading results"
    ./gradlew uploadResults --args="BroadJadeDev.json $outputDir"
    exit $collectMeasurementsExitCode
  fi

  echo "Uploading results"
  ./gradlew uploadResults --args="BroadJadeDev.json $outputDir"

  cd ${GITHUB_WORKSPACE}/${workingDir}
}
