# GCR Cherry-Pick Action

### Overview

Cherry-pick an image from dev to public GCR

### Example Usage

```
    - name: "Cherry-pick UI image to public GCR"
        uses: broadinstitute/datarepo-actions/actions/gcr-cherry-pick@0.37.0
        env:
          GCR_IMG_VERSION: 0.15.0
          GCR_DEV_URL: gcr.io/broad-jade-dev/jade-data-repo-ui
          GCR_PUBLIC_URL: gcr.io/terra-datarepo-production/jade-data-repo-ui
```

### Environment Variables

```
GCR_IMG_VERSION:
  description: Semantic version of image to cherry-pick
  default: none
GCR_DEV_URL:
  description: URL of the dev container registry to cherry-pick from
  default: none
GCR_PUBLIC_URL:
  description: URL of the public container registry to cherry-pick to
  default: none
```
