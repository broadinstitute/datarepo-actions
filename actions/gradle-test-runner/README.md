# Gradle Test Runner Action

### Overview

Run Gradle test runner smoke tests. The `JSON_KEY_FILENAME` must match the value
defined in the [appropriate server resource](https://github.com/DataBiosphere/jade-data-repo/tree/develop/datarepo-clienttests/src/main/resources/servers). 

### Example Usage

```
    - name: "Run Gradle test runner smoke tests in integration-2"
        uses: broadinstitute/datarepo-actions/actions/gradle-test-runner@0.37.0
        env:
          NAMESPACEINUSE: integration-2
          JSON_KEY_FILENAME: jade-dev-account.json
```

### Environment Variables

```
NAMESPACEINUSE:
  description: Which integration namespace to use for Gradle test runner tests
  default: none
JSON_KEY_FILENAME:
  description: Name of the credentials which will be used for test runner tests
  default: none
```
