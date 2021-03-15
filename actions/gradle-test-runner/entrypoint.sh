#!/bin/sh

set -eu

GCLOUD_CREDENTIALS_DIRECTORY_PATH="${GOOGLE_APPLICATION_CREDENTIALS%/*}"
ln -s "${GOOGLE_APPLICATION_CREDENTIALS}" "${GCLOUD_CREDENTIALS_DIRECTORY_PATH}/${JSON_KEY_FILENAME}"

echo "Building Data Repo client library"
ENABLE_SUBPROJECT_TASKS=1 ./gradlew :datarepo-client:clean :datarepo-client:assemble
cd "${GITHUB_WORKSPACE}/datarepo-clienttests"

echo "Setting Test Runner environment variables"
set -x
ORG_GRADLE_PROJECT_DATAREPOCLIENTJAR=$(find .. -type f -name "datarepo-client*.jar")
export ORG_GRADLE_PROJECT_DATAREPOCLIENTJAR
export TEST_RUNNER_SERVER_SPECIFICATION_FILE="${NAMESPACEINUSE}.json"
export TEST_RUNNER_SA_KEY_DIRECTORY_PATH="${GCLOUD_CREDENTIALS_DIRECTORY_PATH}"
set +x

echo "Running spotless and spotbugs"
./gradlew spotlessCheck spotbugsMain

OUTPUTDIR="/tmp/TestRunnerResults"
echo "Output directory set to: $OUTPUTDIR"

echo "Running tests"
./gradlew runTest --args="suites/PRSmokeTests.json $OUTPUTDIR" ||
    (echo "Running tests FAILURE" &&
        ./gradlew uploadResults --args="BroadJadeDev.json $OUTPUTDIR" &&
        return 1)
echo "Running test suite SUCCESS"

echo "Collecting measurements"
./gradlew collectMeasurements --args="PRSmokeTests.json $OUTPUTDIR" ||
    (echo "Collecting measurements FAILURE" &&
        ./gradlew uploadResults --args="BroadJadeDev.json $OUTPUTDIR" &&
        return 1)
echo "Collecting measurements SUCCESS"

echo "Uploading results"
./gradlew uploadResults --args="BroadJadeDev.json $OUTPUTDIR"
