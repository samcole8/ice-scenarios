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
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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

provider "ice" {
  endpoint = "http://localhost:8080"
}

provider "aws" {
  region = var.aws_region
}
