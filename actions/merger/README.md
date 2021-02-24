# Merger Action


### Overview
Commits and merges code changed in earlier steps of workflow

### Example Usage

    - name: 'Checkout repo'
        uses: actions/checkout@v2
        with:
          repository: 'broadinstitute/datarepo-helm-definitions'
          token: ${{ secrets.BROADBOT_TOKEN }}
          path: datarepo-helm-definitions
    - name: "Make change"
        run: <make some change to datarepo-helm-definitions repo here>
    - name: "Merge using new merge action"
        uses: broadinstitute/datarepo-actions/actions/merger@sh-dr-1510-chart-version
        env:
          COMMIT_MESSAGE: "Datarepo Integration mutli chart version update"
          GITHUB_REPO: datarepo-helm-definitions
          SWITCH_DIRECTORIES: "true"

### Important note:
Must check out repo w/ user that has admin access to override 2 thumb requirement. 


### inputs
github_repo:
  description: Used as base directory for merging
  default: jade-data-repo
github_user_email:
  description: User to be configured as commiter
  default: broadbot@broadinstitute.org
github_user_name:
  description: User to be configured as commiter
  default: broadbot
github_workspace:
  description: base directory
commit_msg:
  description: msg provided with commit
  default: "commit merged via github action"
merge_branch:
  description: Branch to merge commit into
switch_directories:
  description: defaults to false, when working with multiple repos set to true
  default: false
