#!/bin/sh

set -eu

# determine which cloud project to use
if [ "${TEST_TO_RUN}" = "testConnected" ]; then
    GOOGLE_CLOUD_DATA_PROJECT="broad-jade-integration-data"
elif [ "${TEST_TO_RUN}" = "testIntegration" ]; then
    GOOGLE_CLOUD_DATA_PROJECT="broad-jade-int-${NAMESPACEINUSE#integration-}-data"
else
    echo "\${TEST_TO_RUN} must be one of testConnected or testIntegration"
    return 1;
fi

PGHOST=$(hostname -i)

# export environment variables for tests
export PGHOST
export PGPORT=5432
export DB_DATAREPO_URI="jdbc:postgresql://${PGHOST}:${PGPORT}/datarepo"
export DB_STAIRWAY_URI="jdbc:postgresql://${PGHOST}:${PGPORT}/stairway"
export GOOGLE_CLOUD_DATA_PROJECT

# check if postgres is ready
pg_isready -h "${PGHOST}" -p "${PGPORT}"
psql -U postgres -f ./db/create-data-repo-db

# assemble code and run tests
./gradlew assemble
./gradlew -w check --scan
./gradlew -w "${TEST_TO_RUN}" --scan
