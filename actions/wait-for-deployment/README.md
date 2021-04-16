# Wait for Deployment Action

### Overview

This action completes a two layered check:
1. If this is an API deployment, we check that the latest git hash is running in the namespace.
2. For both API and UI deployments, we then check that the UI pod is running in the namespace before continuing.

### Example Usage

```
    - name: "Wait for Deployment"
        uses: broadinstitute/datarepo-actions/actions/wait-for-deployment@0.58.0
        env:
          NAMESPACEINUSE: integration-1
          DEPLOYMENT_TYPE: api
          API_URL: 'https://jade-1.datarepo-integration.broadinstitute.org'
          DESIRED_GITHASH: ${{ steps.configuration.outputs.git_hash }}
```

### Environment Variables

```
NAMESPACEINUSE:
  description: Wait for the UI pod to run in this namespace before continuing
  default: none
DEPLOYMENT_TYPE
  description: Declare 'api' or 'ui' deployment
  default: none
API_URL
  description: The url to check the /configuration endpoint for the current running version
  default: none
DESIRED_GITHASH
  description: The git hash against which to compare the current running version
  default: none
```
