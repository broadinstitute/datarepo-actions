# Merger Action


### Overview

Commits and merges code changed in earlier steps of workflow

### Example Usage

```
    - name: 'Checkout repo'
        uses: actions/checkout@v3
        with:
          repository: 'broadinstitute/datarepo-helm-definitions'
          token: ${{ secrets.BROADBOT_TOKEN }}
          path: datarepo-helm-definitions
    - name: "Make change"
        run: <make some change to datarepo-helm-definitions repo here>
    - name: "Merge using new merge action"
        uses: broadinstitute/datarepo-actions/actions/merger@0.37.0
        env:
          COMMIT_MESSAGE: "Datarepo Integration mutli chart version update"
          GITHUB_REPO: datarepo-helm-definitions
          SWITCH_DIRECTORIES: "true"
```

### Important note:

Must check out repo w/ user that has admin access to override 2 thumb requirement. 

### Environment Variables

```
GITHUB_REPO:
  description: Used as base directory for merging
  default: jade-data-repo
GITHUB_USER_EMAIL:
  description: User to be configured as committer
  default: broadbot@broadinstitute.org
GITHUB_USER_NAME:
  description: User to be configured as committer
  default: broadbot
COMMIT_MESSAGE:
  description: msg provided with commit
  default: "commit merged via github action"
MERGE_BRANCH:
  description: Branch to merge commit into
SWITCH_DIRECTORIES:
  description: defaults to false, when working with multiple repos set to true
  default: false
```
