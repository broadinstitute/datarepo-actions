# Clean IAM Policy Action

### Overview

Clean IAM policies in a particular integration namespace

### Example Usage

```
    - name: "Clean IAM policy"
        uses: broadinstitute/datarepo-actions/actions/clean-iam-policy@0.37.0
        env:
          NAMESPACEINUSE: integration-1
```

### Environment Variables

```
NAMESPACEINUSE:
  description: Which integration namespace to use for the IAM cleanup
  default: none
```
