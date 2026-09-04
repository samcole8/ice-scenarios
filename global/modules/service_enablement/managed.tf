resource "proxmox_virtual_environment_file" "grafana_cloud_init" {
  content_type = "snippets"
  datastore_id = "terraform-snippets"
  node_name    = var.node_name

  source_raw {
    file_name = "grafana-cloud-init.yaml"

    data = <<-EOF
      #cloud-config

      users:
        - name: administrator
          groups: sudo
          shell: /bin/bash
          lock_passwd: false
          sudo: ALL=(ALL) NOPASSWD:ALL

      chpasswd:
        list: |
          administrator:password
        expire: false

      ssh_pwauth: true

      package_update: true

      packages:
        - qemu-guest-agent
        - net-tools
        - curl
        - openssh-server
        - apt-transport-https
        - software-properties-common
        - wget
        - gpg

      runcmd:
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
        - systemctl enable ssh
        - systemctl start ssh
        - mkdir -p /etc/apt/keyrings
        - wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor -o /etc/apt/keyrings/grafana.gpg
        - echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" > /etc/apt/sources.list.d/grafana.list
        - apt-get update
        - apt-get install -y grafana loki
        - systemctl enable grafana-server
        - systemctl start grafana-server
        - echo "done" > /tmp/cloud-config.done
    EOF
  }
}

resource "proxmox_virtual_environment_vm" "grafana" {
  name      = "grafana-loki"
  node_name = var.node_name

  clone {
    vm_id = 9000
  }

  agent {
    enabled = true
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.grafana_cloud_init.id
  }

  started = true
}

output "grafana_ip" {
  value = proxmox_virtual_environment_vm.grafana.ipv4_addresses
}

resource "ice_config" "main" {
  system {
    name     = "promtail_host"
    host     = proxmox_virtual_environment_vm.promtail_host.ipv4_addresses[1][0]
    username = "administrator"
    password = "password"

    capability {
      name = "log_shipper_enabled"
      cmd  = "systemctl is-enabled --quiet promtail"
    }
    capability {
      name    = "correct_loki_target"
      cmd     = "grep -q '${proxmox_virtual_environment_vm.grafana.ipv4_addresses[1][0]}' /etc/promtail/config.yaml"
      handler = "promtail_host"
    }
  }

  system {
    name = proxmox_virtual_environment_vm.grafana.name

    requirement {
      name     = "log_shipper_required"
      contract = "log_shipper_enabled"
    }
    requirement {
      name     = "correct_target_configured"
      contract = "correct_loki_target"
    }
  }
}
