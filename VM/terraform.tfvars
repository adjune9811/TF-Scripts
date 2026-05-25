
subscription_id               = "9da3c560-df90-4341-b7c0-160dda0e38c0"
vm_admin_username             = "azuser"
vm_admin_password             = "Password@1234"
resource_group_name           = "RG-TF-CI"
resource_group_location       = "central india"
virtual_network_name          = "TF-CI-Vnet"
virtual_network_address_space = ["10.10.0.0/16"]
subnet_name                   = "vmsubnet"
subnet_address_space          = "10.10.0.0/24"
virtual_machine_name          = "TF-CI-VM"
virtual_machine_size          = "Standard_D2s_v3"
vm_image_publisher            = "MicrosoftWindowsServer"
vm_image_offer                = "WindowsServer"
vm_image_sku                  = "2025-Datacenter"
vm_image_version              = "latest"


