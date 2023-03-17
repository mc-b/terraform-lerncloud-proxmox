###
#   Ressourcen
#

resource "proxmox_vm_qemu" "vm" {
  name        = var.module
  target_node = var.target_node
  vmid        = split("-", var.module)[1] + 1000  

  ### Clone VM operation
  clone = var.template_name

  # basic VM settings here. agent refers to guest agent
  agent    = 1
  os_type  = "cloud-init"
  cores    = var.cores
  memory   = var.memory * 1024
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"
  
  full_clone = false

  ipconfig0 = format("ip=192.168.1.1%s/24,gw=192.168.1.1", split("-", var.module)[1] )
  # Dynamische IP-Adresse via DHCP
  # ipconfig0 = "ip=dhcp" 

  cicustom = "user=local:snippets/${var.userdata}"
  
  /** lernCloud Variante mit setzen Hostname und WireGuard Konfiguration in /opt/wireguard
  connection {
    type     = "ssh"
    host     = self.default_ipv4_address
    user     = "ubuntu"
    password = "insecure"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname  ${var.module}",
      "curl -sfL https://raw.githubusercontent.com/mc-b/lerncloud/main/services/vpn.sh | bash -",    
    ]
  }  
  */
}
