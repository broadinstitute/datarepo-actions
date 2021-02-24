# Merger Action


### Overview
Commits and merges code changed in earlier steps of workflow


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
