# managed.tf

resource "ice_config" "main" {
  system {
    name     = "k8s_cluster"
    host     = proxmox_virtual_environment_vm.k8s_cluster.ipv4_addresses[1][0]
    username = "administrator"
    password = "password"

    capability {
      name = "role_exists"
      cmd  = "kubectl get role microservice-role -n demo --kubeconfig /etc/rancher/k3s/k3s.yaml"
    }
    capability {
      name = "rolebinding_exists"
      cmd  = "kubectl get rolebinding microservice-rolebinding -n demo --kubeconfig /etc/rancher/k3s/k3s.yaml"
    }
    capability {
      name = "clusterrole_exists"
      cmd  = "kubectl get clusterrole microservice-clusterrole --kubeconfig /etc/rancher/k3s/k3s.yaml"
    }
    capability {
      name = "clusterrolebinding_exists"
      cmd  = "kubectl get clusterrolebinding microservice-clusterrolebinding --kubeconfig /etc/rancher/k3s/k3s.yaml"
    }
  }

  system {
    name = "microservice_pod"

    requirement {
      name     = "rbac_permission_granted"
      contract = "(role_exists and rolebinding_exists or clusterrole_exists and clusterrolebinding_exists) and not (role_exists and rolebinding_exists and clusterrole_exists and clusterrolebinding_exists)"
    }
  }
}
