resource "proxmox_virtual_environment_file" "promtail_cloud_init" {
  content_type = "snippets"
  datastore_id = "terraform-snippets"
  node_name    = var.node_name

  source_raw {
    file_name = "promtail-cloud-init.yaml"

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
        - unzip
        - openssh-server

      runcmd:
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
        - systemctl enable ssh
        - systemctl start ssh
        - curl -O -L "https://github.com/grafana/loki/releases/latest/download/promtail-linux-amd64.zip"
        - unzip promtail-linux-amd64.zip
        - mv promtail-linux-amd64 /usr/local/bin/promtail
        - useradd --no-create-home --shell /usr/sbin/nologin promtail
        - mkdir -p /etc/promtail
        - |
          cat <<'UNIT' > /etc/systemd/system/promtail.service
          [Unit]
          Description=Promtail log shipper
          After=network.target

          [Service]
          ExecStart=/usr/local/bin/promtail -config.file=/etc/promtail/config.yaml
          User=promtail

          [Install]
          WantedBy=multi-user.target
          UNIT
        - systemctl daemon-reload
        - systemctl enable promtail
        - systemctl start promtail
    EOF
  }
}

resource "proxmox_virtual_environment_vm" "promtail_host" {
  name      = "promtail-host"
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

    user_data_file_id = proxmox_virtual_environment_file.promtail_cloud_init.id
  }

  started = true
}

output "promtail_ip" {
  value = proxmox_virtual_environment_vm.promtail_host.ipv4_addresses
}
