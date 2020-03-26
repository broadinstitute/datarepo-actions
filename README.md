# datarepo-actions


### Overview

This is a collections of functions that run in a github actions specific to Broadinstitute's Jade team

### inputs
-  actions_subcommand:
    - description: 'subcommand to execute.'
- role_id:
    - description: 'role_id for vault'
-  secret_id:
    - description: 'secret_id for vault'
-  vault_address:
    - description: 'https address for vault'
    - default: 'https://clotho.broadinstitute.org:8200'
-  google_zone:
    - description: 'Google zone for sdk ie:us-central1'
    - default: 'us-central1'
-  google_project:
    - description: 'Google project for sdk ie:broad-jade-integration'
    - default: 'broad-jade-integration'
-  gcr_google_project:
    - description: 'Google project for GCR image ie:broad-jade-dev'
    - default: 'broad-jade-dev'
-  k8_cluster:
    - description: 'Google kubernetes cluster for sdk ie:integration-master'
    - default: 'integration-master'
-  k8_namespaces:
    - description: 'Google kubernetes cluster namespaces must be comma separated ie:"integration-1,integration-2"'
    - default: 'integration-1,integration-2,integration-3,integration-4,integration-5'
-  helm_secret_chart_version:
    - description: 'Helm chart version for datarepo-helm/create-secret-manager-secret ie:0.0.4'
-  helm_datarepo_chart_version:
    - description: 'Helm chart version for datarepo-helm/datarepo ie:0.0.8'
-  actions_working_dir:
    - description: 'working directory.'
    - default: '.'
-  pgport:
    - description: 'postgres port'
-  pgpassword:
    - description: 'postgres password'
    - default: 'postgres'
-  helm_env_prefix:
    - description: 'prefix for helm deploy config comma spearated can be multiple ie:dev,integration-1,integration-2'
    - default: 'dev'
-  helm_imagetag_update:
    - description: 'which image you would like to update the tag of in helm definitions ie:ui or api'
-  test_to_run:
    - description: 'which test you would like to run on the pods ie:testConnected or testIntegration'
