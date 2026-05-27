# Resource group variables
variable "resource_group_name" {
  description = "This is name of resource group"
  type        = string
}

# Resource group location variables
variable "resource_group_location" {
  description = "This is location of resource group"
  type        = string
}

variable "virtual_network_name" {
  description = "This is for virtual network"
  type        = string
}

variable "virtual_network_address_space" {
  description = "This is for virtual network address space"
  type        = list(string)
}

# ─── Windows Subnet ───────────────────────────────────────────────────────────

variable "subnet_name" {
  description = "Subnet name for Windows VMs"
  type        = string
}

variable "subnet_address_space" {
  description = "Address prefix for Windows VM subnet (e.g. 10.10.0.0/24)"
  type        = string
}

# ─── Ubuntu Subnet ────────────────────────────────────────────────────────────

variable "ubuntu_subnet_name" {
  description = "Subnet name for Ubuntu VMs"
  type        = string
}

variable "ubuntu_subnet_address_space" {
  description = "Address prefix for Ubuntu VM subnet (e.g. 10.10.1.0/24)"
  type        = string
}

# ─── Windows VM ───────────────────────────────────────────────────────────────

variable "windows_vm_count" {
  description = "Number of Windows VMs to create (1, 2, or 3)"
  type        = number
  default     = 1

  validation {
    condition     = var.windows_vm_count >= 1 && var.windows_vm_count <= 3
    error_message = "windows_vm_count must be between 1 and 3."
  }
}

variable "virtual_machine_name" {
  description = "Base name for Windows VMs — each VM is suffixed with its index (e.g. TF-CI-VM-1)"
  type        = string
}

variable "virtual_machine_size" {
  description = "SKU / size of the Windows VM (e.g. Standard_D2s_v3)"
  type        = string
}

variable "vm_image_publisher" {
  description = "OS image publisher for Windows VM"
  type        = string
}

variable "vm_image_offer" {
  description = "OS image offer for Windows VM"
  type        = string
}

variable "vm_image_sku" {
  description = "OS image SKU for Windows VM"
  type        = string
}

variable "vm_image_version" {
  description = "OS image version for Windows VM"
  type        = string
}

variable "vm_admin_username" {
  description = "Admin username for Windows VMs"
  type        = string
}

variable "vm_admin_password" {
  description = "Admin password for Windows VMs"
  type        = string
  sensitive   = true
}

# ─── Ubuntu VM ────────────────────────────────────────────────────────────────

variable "ubuntu_vm_count" {
  description = "Number of Ubuntu VMs to create (1, 2, or 3)"
  type        = number
  default     = 1

  validation {
    condition     = var.ubuntu_vm_count >= 1 && var.ubuntu_vm_count <= 3
    error_message = "ubuntu_vm_count must be between 1 and 3."
  }
}

variable "ubuntu_vm_name" {
  description = "Base name for Ubuntu VMs — each VM is suffixed with its index (e.g. TF-CI-Ubuntu-1)"
  type        = string
}

variable "ubuntu_vm_size" {
  description = "SKU / size of the Ubuntu VM (e.g. Standard_B2s)"
  type        = string
}

variable "ubuntu_vm_image_publisher" {
  description = "OS image publisher for Ubuntu VM"
  type        = string
}

variable "ubuntu_vm_image_offer" {
  description = "OS image offer for Ubuntu VM"
  type        = string
}

variable "ubuntu_vm_image_sku" {
  description = "OS image SKU for Ubuntu VM"
  type        = string
}

variable "ubuntu_vm_image_version" {
  description = "OS image version for Ubuntu VM"
  type        = string
}

variable "ubuntu_vm_admin_username" {
  description = "Admin username for Ubuntu VMs"
  type        = string
}

variable "ubuntu_vm_admin_password" {
  description = "Admin password for Ubuntu VMs"
  type        = string
  sensitive   = true
}

# ─── Subscription ─────────────────────────────────────────────────────────────

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}
