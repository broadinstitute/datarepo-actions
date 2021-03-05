# Add Runner IP Action

### Overview

Adds the Runner IP to the Kubernetes allowlist

### Example Usage

```
    - name: "Add the Runner IP to the k8s allowlist"
        uses: broadinstitute/datarepo-actions/actions/add-runner-ip@0.37.0
        env:
          K8_CLUSTER: integration-master
```

### Environment Variables

```
K8_CLUSTER:
  description: Which Kubernetes cluster should be used for the allowlist
  default: none
```
