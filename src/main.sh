#!/bin/bash

set -e

parseInputs () {
  # Required inputs
  if [ "${INPUT_ACTIONS_SUBCOMMAND}" != "" ]; then
    export subcommand=${INPUT_ACTIONS_SUBCOMMAND}
  else
    echo "Input subcommand cannot be empty"
    exit 1
  fi

  # Optional inputs
  role_id=""
  if [ -n "${INPUT_ROLE_ID}" ]; then
    export role_id=${INPUT_ROLE_ID}
  fi
  secret_id=""
  if [ -n "${INPUT_SECRET_ID}" ]; then
    export secret_id=${INPUT_SECRET_ID}
  fi
  export vault_address="${INPUT_VAULT_ADDRESS}"
  export google_zone="${INPUT_GOOGLE_ZONE}"
  export google_project="${INPUT_GOOGLE_PROJECT}"
  export DEV_PROJECT="${INPUT_GCR_GOOGLE_PROJECT}"
  k8_namespaces=""
  if [ -n "${INPUT_K8_NAMESPACES}" ]; then
    export k8_namespaces="${INPUT_K8_NAMESPACES}"
  fi
  helm_create_secret_manager_secret_version=""
  if [ -n "${INPUT_helm_create_secret_manager_secret_version}" ]; then
    export helm_create_secret_manager_secret_version="${INPUT_helm_create_secret_manager_secret_version}"
  fi
  helm_datarepo_api_chart_version=""
  if [ -n "${INPUT_HELM_DATAREPO_API_CHART_VERSION}" ]; then
    export helm_datarepo_api_chart_version="${INPUT_HELM_DATAREPO_API_CHART_VERSION}"
  fi
  helm_datarepo_ui_chart_version=""
  if [ -n "${INPUT_HELM_DATAREPO_UI_CHART_VERSION}" ]; then
    export helm_datarepo_ui_chart_version="${INPUT_HELM_DATAREPO_UI_CHART_VERSION}"
  fi
  helm_oidc_proxy_chart_version=""
  if [ -n "${INPUT_HELM_OIDC_PROXY_CHART_VERSION}" ]; then
    export helm_oidc_proxy_chart_version="${INPUT_OIDC_PROXY_CHART_VERSION}"
  fi
  helm_gcloud_sqlproxy_chart_version=""
  if [ -n "${INPUT_HELM_GCLOUD_SQLPROXY_CHART_VERSION}" ]; then
    export helm_gcloud_sqlproxy_chart_version="${INPUT_GCLOUD_SQLPROXY_CHART_VERSION}"
  fi
  workingDir="."
  if [[ -n "${INPUT_ACTIONS_WORKING_DIR}" ]]; then
    export workingDir=${INPUT_ACTIONS_WORKING_DIR}
  fi
  export PGPASSWORD=${INPUT_PGPASSWORD}
  PGPORT=""
  if [[ -n "${INPUT_PGPORT}" ]]; then
    export PGPORT=${INPUT_PGPORT}
  fi
  if [[ -n "${INPUT_HELM_ENV_PREFIX}" ]]; then
    export helm_env_prefix=${INPUT_HELM_ENV_PREFIX}
  fi
  helm_imagetag_update=""
  if [[ -n "${INPUT_HELM_IMAGETAG_UPDATE}" ]]; then
    export helm_imagetag_update=${INPUT_HELM_IMAGETAG_UPDATE}
  fi
  test_to_run=""
  if [[ -n "${INPUT_TEST_TO_RUN}" ]]; then
    export test_to_run=${INPUT_TEST_TO_RUN}
  fi
  release_name=""
  if [[ -n "${INPUT_RELEASE_NAME}" ]]; then
    export release_name=${INPUT_RELEASE_NAME}
  fi
  alpharelease=""
  if [[ -n "${INPUT_ALPHARELEASE}" ]]; then
    export alpharelease=${INPUT_ALPHARELEASE}
  fi
export helm_charts_to_test=${INPUT_HELM_CHARTS_TO_TEST}
# non chanable vars for testing
}

configureCredentials () {
  if [ -f env_vars ]; then
    echo "sourcing environment vars for configureCredentials"
    eval $(cat env_vars)
  else
    echo "Skipping importing environment vars for configureCredentials"
  fi
  if [[ "$VAULT_TOKEN" != "" ]]; then
    echo "Vault token already set skipping configureCredentials function"
  elif [[ "${role_id}" != "" ]] && [[ "${secret_id}" != "" ]] && [[ "${vault_address}" != "" ]]; then
    export VAULT_ADDR=${vault_address}
    export VAULT_TOKEN=$(curl \
      --request POST \
      --data '{"role_id":"'"${role_id}"'","secret_id":"'"${secret_id}"'"}' \
      ${vault_address}/v1/auth/approle/login | jq -r .auth.client_token)
      echo "export VAULT_TOKEN=${VAULT_TOKEN}" >> env_vars
    /usr/local/bin/vault read -format=json secret/dsde/datarepo/dev/sa-key.json | \
      jq .data > ${GOOGLE_APPLICATION_CREDENTIALS}
    jq -r .private_key ${GOOGLE_APPLICATION_CREDENTIALS} > ${GOOGLE_SA_CERT}
    chmod 600 ${GOOGLE_SA_CERT}
    echo 'Configured google sdk credentials from vault'
  else
    echo "required var not defined for function configureCredentials"
    exit 1
  fi
}

googleAuth () {
  account_status=""
  account_status=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
  if [[ "${account_status}" != "" ]]; then
    echo "Service account has already been activated skipping googleAuth function"
  elif [[ "${google_zone}" != "" ]] && [[ "${google_project}" != "" ]]; then
    gcloud auth activate-service-account --key-file ${GOOGLE_APPLICATION_CREDENTIALS}
    # configure integration prerequisites
    gcloud config set compute/zone ${google_zone} --quiet
    gcloud config set project ${google_project} --quiet
    gcloud auth configure-docker --quiet
    echo 'Set google sdk to SA user'
    if [[ -n "${K8_CLUSTER}" ]]; then
      gcloud container clusters get-credentials ${K8_CLUSTER} --zone ${google_zone}
    fi
  else
    echo "Required var not defined for function googleAuth"
    exit 1
  fi
}

helmprerun () {
  if [ -f helmprerundone ]; then
    printf "Skipping helmprerun\n"
  else
    helm plugin install https://github.com/thomastaylor312/helm-namespace
    helm repo add datarepo-helm https://broadinstitute.github.io/datarepo-helm
    helm repo update
    touch helmprerundone
  fi
}

main () {
  # Source the other files to gain access to their functions
  scriptDir=$(dirname ${0})
  source ${scriptDir}/whitelist.sh
  source ${scriptDir}/checknamespace.sh
  source ${scriptDir}/helmdeploy.sh
  source ${scriptDir}/whitelistclean.sh
  source ${scriptDir}/checknamespaceclean.sh
  source ${scriptDir}/gradlebuild.sh
  source ${scriptDir}/gradleinttest.sh
  source ${scriptDir}/gradletestrunnersmoketest.sh
  source ${scriptDir}/deploytagupdate.sh
  source ${scriptDir}/waitfordeployment.sh
  source ${scriptDir}/charttestdeploy.sh
  source ${scriptDir}/charttestdelete.sh
  source ${scriptDir}/testcharts.sh
  source ${scriptDir}/bumper.sh
  source ${scriptDir}/alpharelease.sh

  parseInputs
  helmprerun
  configureCredentials
  googleAuth
  if [[ "${subcommand}" == "skip" ]]; then
    echo "skipping any sub command, only getting gcp creds"
  else
    cd ${GITHUB_WORKSPACE}/${workingDir}

    case "${subcommand}" in
      gcp_whitelist)
        whitelist ${*}
        ;;
      k8_checknamespace)
        checknamespace ${*}
        ;;
      helmdeploy)
        helmdeploy ${*}
        ;;
      gcp_whitelist_clean)
        whitelistclean ${*}
        ;;
      k8_checknamespace_clean)
        checknamespaceclean ${*}
        ;;
      gradlebuild)
        gradlebuild ${*}
        ;;
      gradleinttest)
        gradleinttest ${*}
        ;;
      gradletestrunnersmoketest)
        gradletestrunnersmoketest ${*}
        ;;
      deploytagupdate)
        deploytagupdate ${*}
        ;;
      wait_for_deployment)
        waitfordeployment ${*}
        ;;
      charttestdeploy)
        charttestdeploy ${*}
        ;;
      charttestdelete)
        charttestdelete ${*}
        ;;
      testcharts)
        testcharts ${*}
        ;;
      bumper)
        bumper ${*}
        ;;
      alpharelease)
        alpharelease ${*}
        ;;
      *)
        echo "Error: Must provide a valid value for actions_subcommand"
        exit 1
        ;;
    esac
  fi
}

main "${*}"
