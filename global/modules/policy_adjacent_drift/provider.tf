terraform {
  required_providers {
    ice = {
      source  = "samcole8/ice"
      version = "0.1.0"
    }
    aws = {
      source = "hashicorp/aws"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
