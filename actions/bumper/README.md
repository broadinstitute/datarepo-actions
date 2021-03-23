# Semantic Version Bumper Action

### Overview

Bumps the git tag to a new semantic version

### Example Usage

```
    - name: "Bump semantic version tag"
      uses: broadinstitute/datarepo-actions/actions/bumper@0.37.0
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        release_branch_list: develop
        semver_bump: minor
        version_file_path: build.gradle
```

### Inputs

```
github_token:
  description: "Authentication token required for adding semantic version to repository"
  required: true
release_branch_list:
  description: "Comma separated list of branches to semantically version"
  default: develop,master
semver_bump:
  description: "Whether to bump the major, minor, or patch portion of the semantic version"
  default: minor
version_file_path:
  description: "Bump the semantic version in this file"
  default:
initial_version:
  description: "Which version to use as the first semantic version"
  default: 0.0.0
semver_with_v:
  description: "Whether or not the semantic version should be prefixed with a 'v'"
  default: false
```
