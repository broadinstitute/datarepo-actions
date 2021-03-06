# Add Runner IP Action

### Overview

Configures Google Cloud SDK

### Example Usage

```
    - name: "Configure GCloud SDK"
        uses: broadinstitute/datarepo-actions/actions/configure-gcloud-sdk@0.37.0
        env:
          GOOGLE_APPLICATION_CREDENTIALS: /tmp/jade-dev-account.json
          GOOGLE_CLOUD_PROJECT: broad-jade-integration
          GOOGLE_REGION: us-central1
          K8_CLUSTER: integration-master
```

### Environment Variables

```
GOOGLE_APPLICATION_CREDENTIALS:
  description: Location of key file for authentication using a service account
GOOGLE_CLOUD_PROJECT:
  description: Google project name to set after authentication
GOOGLE_REGION:
  description: Google region to set after authentication
K8_CLUSTER:
  description: Kubernetes cluster from which to get credentials
  optional: true
```
