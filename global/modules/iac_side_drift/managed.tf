
resource "ice_config" "main" {
  system {
    name     = "postgres"
    host     = proxmox_virtual_environment_vm.postgres_db.ipv4_addresses[1][0]
    username = "administrator"
    password = "password"

    capability {
      name = "max_connections_sufficient"
      cmd  = "grep -q '^max_connections = 100' /etc/postgresql/*/main/postgresql.conf"
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
