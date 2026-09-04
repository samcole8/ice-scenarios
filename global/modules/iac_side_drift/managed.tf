
resource "ice_config" "main" {
  system {
    name = "postgres"

    capability {
      name  = "max_connections_sufficient"
      state = var.actual_max_connections >= 100
    }
  }

  system {
    name = "app_server"

    requirement {
      name     = "db_capacity_required"
      contract = "max_connections_sufficient"
    }
  }
}
