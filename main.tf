###
#   Ressourcen
#

resource "proxmox_vm_qemu" "vm" {
  name        = var.module
  target_node = var.target_node
  vmid        = regex("[0-9]+", var.module) + 1000  

  ### Clone VM operation
  clone = var.template_name

  # basic VM settings here. agent refers to guest agent
  agent    = 1
  os_type  = "cloud-init"
  cores    = var.cores
  memory   = var.memory * 1024
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  ipconfig0 = format("ip=192.168.1.1%s/24,gw=192.168.1.1", split("-", var.module)[1] )

  cicustom = "user=local:snippets/${var.userdata}"
}






