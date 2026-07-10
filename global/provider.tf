terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.86.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.ip
  insecure = true
  username = "root@pam"
  password = var.password
  ssh {
    agent    = false
    username = "root@pam"
    password = var.password
  }
}

