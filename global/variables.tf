variable "password" {
  type        = string
  description = "Endpoint for the Proxmox Virtual Environment"
  default     = "192.168.1.230:8006"
}

variable "ip" {
  type        = string
  description = "Root password for the Proxmox Virtual Environment"
  default     = "password"
  sensitive   = true
}
