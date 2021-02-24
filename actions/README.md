# Overview

Github actions to be used by jade-data-repo and associated repositories. 

# Example Usage

```
- name: "Merge using new merge action"
    uses: broadinstitute/datarepo-actions/actions/merger@0.37.0
```

# Adding new actions

Note of caution to carefully select the base docker image based on libaries and tools that will need to be installed. 
Examples:
- [debian/buster-slim](https://hub.docker.com/_/debian) - Should work well with most of the tools we use
- openjdk:8-slim - we use in our "main" action, works well when we need Java pre-installed
- alpine - we use (alpine/git)[https://hub.docker.com/r/alpine/git/tags/?page=1&ordering=last_updated] in our "merger" action

