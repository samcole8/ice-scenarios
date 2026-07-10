variable "ip" {
  type        = string
  description = "Endpoint for the Proxmox Virtual Environment"
  default     = "https://192.168.122.230:8006/"
}

variable "password" {
  type        = string
  description = "Root password for the Proxmox Virtual Environment"
  default     = "password"
  sensitive   = true
}

variable "node_name" {
  type        = string
  description = "Proxmox node name"
  default     = "pve"
  sensitive   = true
}
