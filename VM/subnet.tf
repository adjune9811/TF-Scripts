resource "azurerm_subnet" "demo-subnet" {
  name                 = "demo-subnet"
  virtual_network_name = azurerm_virtual_network.tf-vnet.name
  resource_group_name  = azurerm_resource_group.tf-rg.name
  address_prefixes     = ["10.10.1.0/24"]

depends_on = [azurerm_virtual_network.tf-vnet, azurerm_resource_group.tf-rg  ]
}