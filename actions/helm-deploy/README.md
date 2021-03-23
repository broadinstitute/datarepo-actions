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
helm_create_secret_manager_secret_version:
  description: "Helm chart version for datarepo-helm/create-secret-manager-secret ie:0.0.4"
  default: ""
helm_datarepo_api_chart_version:
  description: "Helm chart version for datarepo-helm/datarepo ie:0.0.8"
  default: ""
helm_datarepo_ui_chart_version:
  description: "Helm chart version for datarepo-helm/datarepo ie:0.0.8"
  default: ""
helm_oidc_proxy_chart_version:
  description: "Helm chart version for datarepo-helm/datarepo ie:0.0.8"
  default: ""
helm_gcloud_sqlproxy_chart_version:
  description: "Helm chart version for datarepo-helm/datarepo ie:0.0.8"
  default: ""
helm_imagetag_update:
  description: "api or ui"
  default: ""
```
