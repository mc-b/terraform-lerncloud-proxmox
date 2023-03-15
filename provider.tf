###
#   Provider 
#

terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 2.9.13"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.url
  pm_user         = var.user
  pm_password     = var.key
  pm_tls_insecure = true

  /* Aktivieren um Probleme zu finden
  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
  pm_debug      = true
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
  */
}
