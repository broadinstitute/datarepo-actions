# Unlock Namespace Action

### Overview

Unlock namespace for use

### Example Usage

```
    - name: "Unlock namespace for use"
        uses: broadinstitute/datarepo-actions/actions/unlock-namespace@0.37.0
        env:
          NAMESPACEINUSE: integration-1
```

### Environment Variables

```
NAMESPACEINUSE:
  description: Unlock namespace for use
  default: none
```
