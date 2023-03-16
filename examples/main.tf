###
# Basis VM

module "lerncloud" {
  source     = "git::https://github.com/mc-b/terraform-lerncloud-proxmox" 
  # zum Testen  
  # source     = "../"      

  # Module Info
  module      = "test-60"
  description = "Test Modul"
  userdata    = "cloud-init.yaml"

  # VM Sizes  
  #memory   = 2
  #cores    = 1
  #storage  = 32
  #ports    = [ 22, 80 ]
}

