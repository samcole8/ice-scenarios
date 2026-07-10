terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.111.0"
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
    username = "root"
    password = var.password
  }
}

