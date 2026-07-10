

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve"
  url          = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  file_name    = "noble-server-cloudimg-amd64.qcow2.img"
}

resource "proxmox_virtual_environment_vm" "ubuntu_template" {
  name      = "ubuntu-24.04-template"
  node_name = var.node_name
  template  = true
  started   = false
  machine   = "q35"
  bios      = "ovmf"

  cpu { cores = 2 }
  memory { dedicated = 2048 }

  efi_disk {
    datastore_id = "local-lvm"
    type         = "4m"
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    size         = 20
  }

  initialization {
    user_account {
      username = "administrator"
      password = "password"
    }
    user_data_file_id = proxmox_virtual_environment_file.user_data.id
  }

  network_device { bridge = "vmbr0" }
  agent { enabled = true }
}


resource "proxmox_storage_directory" "snippets" {
  id    = "terraform-snippets"
  path  = "/var/lib/vz/terraform-snippets"
  nodes = ["pve"]

  content = [
    "snippets"
  ]
}

resource "proxmox_virtual_environment_file" "user_data" {
  depends_on   = [proxmox_storage_directory.snippets]
  content_type = "snippets"
  datastore_id = "terraform-snippets"
  node_name    = var.node_name

  source_raw {
    file_name = "enable-password-auth.yaml"
    data      = <<-EOF
    #cloud-config
    ssh_pwauth: true
    EOF
  }
}


