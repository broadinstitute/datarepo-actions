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
- [debian slim image](https://hub.docker.com/layers/debian/library/debian/buster-slim/images/sha256-7f5c2603ccccb7fa4fc934bad5494ee9f47a5708ed0233f5cd9200fe616002ad?context=explore) - Should work well with most of the tools we use
- openjdk:8-slim - we use in our "main" action, works well when we need Java pre-installed
- alpine - we use (alpine/git)[https://hub.docker.com/r/alpine/git/tags/?page=1&ordering=last_updated] in our "merger" action


