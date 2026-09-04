# unmanaged.tf

resource "proxmox_virtual_environment_file" "k8s_cloud_init" {
  content_type = "snippets"
  datastore_id = "terraform-snippets"
  node_name    = var.node_name

  source_raw {
    file_name = "k8s-cloud-init.yaml"

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

      runcmd:
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
        - systemctl enable ssh
        - systemctl start ssh
        - curl -sfL https://get.k3s.io | sh -
        - chmod 644 /etc/rancher/k3s/k3s.yaml
        - until kubectl get nodes --kubeconfig /etc/rancher/k3s/k3s.yaml; do sleep 2; done
        - |
          cat <<'EOM' > /tmp/setup.yaml
          apiVersion: v1
          kind: Namespace
          metadata:
            name: demo
          ---
          apiVersion: v1
          kind: ServiceAccount
          metadata:
            name: microservice-sa
            namespace: demo
          ---
          apiVersion: v1
          kind: Pod
          metadata:
            name: microservice-pod
            namespace: demo
          spec:
            serviceAccountName: microservice-sa
            containers:
              - name: app
                image: busybox
                command: ["sleep", "infinity"]
          ---
          apiVersion: rbac.authorization.k8s.io/v1
          kind: Role
          metadata:
            name: microservice-role
            namespace: demo
          rules:
            - apiGroups: [""]
              resources: ["secrets"]
              verbs: ["get", "list"]
          ---
          apiVersion: rbac.authorization.k8s.io/v1
          kind: RoleBinding
          metadata:
            name: microservice-rolebinding
            namespace: demo
          subjects:
            - kind: ServiceAccount
              name: microservice-sa
              namespace: demo
          roleRef:
            kind: Role
            name: microservice-role
            apiGroup: rbac.authorization.k8s.io
          EOM
        - kubectl apply -f /tmp/setup.yaml --kubeconfig /etc/rancher/k3s/k3s.yaml
        - echo "done" > /tmp/cloud-config.done
    EOF
  }
}

resource "proxmox_virtual_environment_vm" "k8s_cluster" {
  name      = "k8s-cluster"
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

    user_data_file_id = proxmox_virtual_environment_file.k8s_cloud_init.id
  }

  started = true
}

output "k8s_ip" {
  value = proxmox_virtual_environment_vm.k8s_cluster.ipv4_addresses
}
