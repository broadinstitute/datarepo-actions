# Helm Deploy Action

### Overview

Deploys new helm version to new integration deployment

### Example Usage

```
    - name: "Deploy to cluster with helm"
        uses: broadinstitute/datarepo-actions/actions/helm-deploy@0.37.0
        env:
          NAMESPACEINUSE: 'integration-1'
        with:
          helm_imagetag_update: 'api'
          helm_create_secret_manager_secret_version: '0.0.6'
          helm_datarepo_api_chart_version: 0.0.49
          helm_datarepo_ui_chart_version: 0.0.37
          helm_gcloud_sqlproxy_chart_version: 0.19.7
          helm_oidc_proxy_chart_version: 0.0.20
```

### Environment Variables

```
NAMESPACEINUSE
  description: "The integration namespace to use for the helm deployment"
```

### Inputs

```
HELM_CREATE_SECRET_MANAGER_SECRET_VERSION:
  description: "Helm chart version for datarepo-helm/create-secret-manager-secret ie:0.0.4"
  default: ""
HELM_DATAREPO_API_CHART_VERSION:
  description: "Helm chart version for datarepo-helm/datarepo ie:0.0.8"
  default: ""
HELM_DATAREPO_UI_CHART_VERSION:
  description: "Helm chart version for datarepo-helm/datarepo ie:0.0.8"
  default: ""
HELM_OIDC_PROXY_CHART_VERSION:
  description: "Helm chart version for datarepo-helm/datarepo ie:0.0.8"
  default: ""
HELM_GCLOUD_SQLPROXY_CHART_VERSION:
  description: "Helm chart version for datarepo-helm/datarepo ie:0.0.8"
  default: ""
HELM_IMAGETAG_UPDATE:
  description: "api or ui"
  default: ""
```
