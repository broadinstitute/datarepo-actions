# Wait for Deployment Action

### Overview

Ensure that the UI pod is running in the namespace before continuing

### Example Usage

```
    - name: "Wait for Deployment"
        uses: broadinstitute/datarepo-actions/actions/wait-for-deployment@0.37.0
        env:
          NAMESPACEINUSE: integration-1
```

### Environment Variables

```
NAMESPACEINUSE:
  description: Wait for the UI pod to run in this namespace before continuing
  default: none
```
