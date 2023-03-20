
# Allgemeine Variablen

variable "module" {
  description = "Modulname: wird als Hostname und zum Bestimmen der IP-Adresse verwendet"
  type        = string
  default     = "base-10"
}

variable "description" {
  description = "Beschreibung VM"
  type        = string
  default     = "Beschreibung VM"
}

variable "memory" {
  description = "Memory in GB: bestimmt Instance in der Cloud"
  type        = number
  default     = 2
}

variable "storage" {
  description = "Groesse Disk"
  type        = number
  default     = 12
}

variable "cores" {
  description = "Anzahl CPUs"
  type        = number
  default     = 1
}

variable "ports" {
  description = "Ports welche in der Firewall geoeffnet sind"
  type        = list(number)
  default     = [22, 80]
}

variable "userdata" {
  description = "Cloud-init Script"
  type        = string
  default     = "cloud-init.yaml"
}

# Zugriffs Informationen

variable "url" {
  description = "URL fuer den Zugriff auf das API des Proxmox Servers"
  type        = string
  default     = "https://localhost:8006/api2/json"
}

variable "user" {
  description = "Username"
  type        = string
  default     = "terraform-prov@pve"
}

variable "key" {
  description = "API Key oder Password"
  type        = string
  sensitive   = true
  default     = "insecure"
}

# auf welcher Node wird die VM erstellt
variable "target_node" {
  default = "pve"
}

# Template, muss vorher erstellt werden.
variable "template_name" {
  default = "ubuntu-2204-cloudinit-template"
}

variable "vpn" {
  description = "Optional VPN welches eingerichtet werden soll"
  type        = string
  default     = "default"
}
