terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.111.0"
    }
    ice = {
      source  = "samcole8/ice"
      version = "0.1.0"
    }
  }
}
