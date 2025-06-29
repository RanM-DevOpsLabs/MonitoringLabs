terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.0"
    }
  }
}

provider "grafana" {
  url  = "http://localhost:3000"
  auth = "admin:admin"
}

# source: https://grafana.com/grafana/dashboards
resource "grafana_dashboard" "node_exporter_full_dashboard" {
  config_json = file("${path.module}/1860_rev41.json")
}