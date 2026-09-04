variable "node_name" {
  type        = string
  description = "Proxmox node name"
  default     = "pve"
  sensitive   = true
}

variable "max_connections" {
  default = 10
}
