# Lock Namespace Action

### Overview

Lock namespace for use

### Example Usage

```
    - name: "Lock namespace for use"
        uses: broadinstitute/datarepo-actions/actions/lock-namespace@0.37.0
        env:
          K8_NAMESPACES: "integration-1,integration-2,integration-3,integration-6"
```

### Environment Variables

```
K8_NAMESPACES:
  description: Comma seperated list of namespaces to use
  default: none
```
