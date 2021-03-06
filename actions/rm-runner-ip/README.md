# Remove Runner IP Action

### Overview

Removes the Runner IP from the Kubernetes allowlist

### Example Usage

```
    - name: "Remove the Runner IP from the k8s allowlist"
        uses: broadinstitute/datarepo-actions/actions/rm-runner-ip@0.37.0
        env:
          K8_CLUSTER: integration-master
```

### Environment Variables

```
K8_CLUSTER:
  description: Which Kubernetes cluster should be used for the allowlist
  default: none
```
