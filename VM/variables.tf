# Resource group variables

variable "resource_group_name" {
  description = "This is name of resource group"
  type        = string
  //  default = terraform-rg
}


# Resource group location variables

variable "resource_group_location" {
  description = "This is location of resource group"
  type        = string
  // default = eastus
}


variable "virtual_network_name" {
  description = "This is for virtual network"
  type        = string

}

variable "virtual_network_address_space" {
  description = "This is for virtual network address space"
  type        = list(string)

}

variable "subnet_name" {
  description = "This is for subnet name"
  type        = string

}


variable "subnet_address_space" {
  description = "This is for subnet address space"
  type        = string

}

variable "virtual_machine_name" {
  description = "This is name of the virutal machine"
  type        = string
  // default = eastus
}

variable "virtual_machine_size" {
  description = "This is the size/SKU of the virtual machine"
  type        = string
}

variable "vm_image_publisher" {
  description = "This is the OS image publisher"
  type        = string
}

variable "vm_image_offer" {
  description = "This is the OS image offer"
  type        = string
}

variable "vm_image_sku" {
  description = "This is the OS image SKU"
  type        = string
}

variable "vm_image_version" {
  description = "This is the OS image version"
  type        = string
}

variable "subscription_id" {
  description = "This is the Azure subscription ID"
  type        = string
}

variable "vm_admin_username" {
  description = "This is the admin username for the virtual machine"
  type        = string
}

variable "vm_admin_password" {
  description = "This is the admin password for the virtual machine"
  type        = string
  sensitive   = true
}
