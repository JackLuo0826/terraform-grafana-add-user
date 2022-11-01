terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "jackluo"
    workspaces {
      tags = ["platform-grafana-access"]
    }
  }
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "1.30.0"
    }
  }
}

provider "grafana" {
  alias         = "cloud"
  cloud_api_key = var.grafana-auth
}

provider "grafana" {
  alias = "stack"

  url  = data.grafana_cloud_stack.stack.url
  auth = grafana_api_key.management.key
}

provider "grafana" {
  alias = "basic"

  url  = data.grafana_cloud_stack.stack.url
  auth = var.grafana-basic-auth
}
