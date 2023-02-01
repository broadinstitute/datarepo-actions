# Deploy Tag Update Action

### Overview

Updates the datarepo-helm-definitions dev image tag to the latest version. This
requires that the checkout step include `fetch-depth: 0` to pull all the tags.

### Example Usage

```
    - name: Checkout jade-data-repo
        uses: actions/checkout@v3
        with:
          fetch-depth: 0
    - name: Deploy the latest dev image tag to datarepo-helm-definitions
        uses: broadinstitute/datarepo-actions/actions/deploy-tag-update@0.37.0
```
