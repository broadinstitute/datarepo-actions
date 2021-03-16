# Gradle Connected Integration Action

### Overview

Runs Gradle connected and integration tests.

### Example Usage

```
    - name: "Run Gradle connected tests in integration-2"
        uses: broadinstitute/datarepo-actions/actions/gradle-connected-integration@0.37.0
        env:
          NAMESPACEINUSE: integration-2
          TEST_TO_RUN: testConnected
```

### Environment Variables

```
NAMESPACEINUSE:
  description: Which integration namespace to use for Gradle connected and integration tests
  default: none
TEST_TO_RUN:
  description: Name of test to run, either testConnected or testIntegration
  default: none
```
