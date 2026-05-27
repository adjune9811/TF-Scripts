# 2  Resource — Virtual Network
resource "azurerm_virtual_network" "tf-vnet" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  address_space       = var.virtual_network_address_space

  depends_on = [azurerm_resource_group.tf-rg]
}

# 3a Resource — Windows VM Subnet
resource "azurerm_subnet" "tf-subnet" {
  name                 = var.subnet_name
  virtual_network_name = azurerm_virtual_network.tf-vnet.name
  resource_group_name  = azurerm_resource_group.tf-rg.name
  address_prefixes     = [var.subnet_address_space]

  depends_on = [azurerm_virtual_network.tf-vnet, azurerm_resource_group.tf-rg]
}

# 3b Resource — Ubuntu VM Subnet (separate from Windows)
resource "azurerm_subnet" "tf-ubuntu-subnet" {
  name                 = var.ubuntu_subnet_name
  virtual_network_name = azurerm_virtual_network.tf-vnet.name
  resource_group_name  = azurerm_resource_group.tf-rg.name
  address_prefixes     = [var.ubuntu_subnet_address_space]

  depends_on = [azurerm_virtual_network.tf-vnet, azurerm_resource_group.tf-rg]
}

# 4a Resource — Windows Public IPs (one per VM instance)
resource "azurerm_public_ip" "tf-pip" {
  count               = var.windows_vm_count
  name                = "windows-pip-${count.index + 1}"
  allocation_method   = "Static"
  sku                 = "Standard"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  domain_name_label   = "${lower(var.virtual_machine_name)}-${count.index + 1}"
}

# 4b Resource — Ubuntu Public IPs (one per VM instance)
resource "azurerm_public_ip" "tf-ubuntu-pip" {
  count               = var.ubuntu_vm_count
  name                = "ubuntu-pip-${count.index + 1}"
  allocation_method   = "Static"
  sku                 = "Standard"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name
  domain_name_label   = "${lower(var.ubuntu_vm_name)}-${count.index + 1}"
}

# 5a Resource — Windows Network Interfaces (one per VM instance)
resource "azurerm_network_interface" "tf-nic" {
  count               = var.windows_vm_count
  name                = "windows-nic-${count.index + 1}"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tf-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tf-pip[count.index].id
  }

  depends_on = [azurerm_resource_group.tf-rg, azurerm_virtual_network.tf-vnet]
}

# 5b Resource — Ubuntu Network Interfaces (one per VM instance)
resource "azurerm_network_interface" "tf-ubuntu-nic" {
  count               = var.ubuntu_vm_count
  name                = "ubuntu-nic-${count.index + 1}"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tf-ubuntu-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tf-ubuntu-pip[count.index].id
  }

  depends_on = [azurerm_resource_group.tf-rg, azurerm_virtual_network.tf-vnet]
}

# 6  Resource — Network Security Group (shared by both subnets)
resource "azurerm_network_security_group" "tf-nsg" {
  name                = "Tf-nsg"
  location            = azurerm_resource_group.tf-rg.location
  resource_group_name = azurerm_resource_group.tf-rg.name

  security_rule {
    name                       = "allowed-allnetwork"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [azurerm_resource_group.tf-rg, azurerm_virtual_network.tf-vnet]

  tags = {
    environment = "Production"
  }
}

# Associate NSG with Windows subnet
resource "azurerm_subnet_network_security_group_association" "tf-nsg-assoc" {
  subnet_id                 = azurerm_subnet.tf-subnet.id
  network_security_group_id = azurerm_network_security_group.tf-nsg.id
}

# Associate NSG with Ubuntu subnet
resource "azurerm_subnet_network_security_group_association" "tf-ubuntu-nsg-assoc" {
  subnet_id                 = azurerm_subnet.tf-ubuntu-subnet.id
  network_security_group_id = azurerm_network_security_group.tf-nsg.id
}
