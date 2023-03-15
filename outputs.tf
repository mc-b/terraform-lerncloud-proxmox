###
#   Outputs wie IP-Adresse und DNS Name
#  


output "ip_vm" {
  value       = proxmox_vm_qemu.vm.default_ipv4_address
  description = "The IP address of the server instance."
}

output "fqdn_vm" {
  value       = proxmox_vm_qemu.vm.name
  description = "The FQDN of the server instance."
}


output "description" {
  value       = var.description
  description = "Description VM"
}