# ─── Windows Virtual Machines ────────────────────────────────────────────────
# count is driven by var.windows_vm_count (default 1 — change to 2 or 3 in tfvars)

resource "azurerm_windows_virtual_machine" "tf-windows" {
  count               = var.windows_vm_count
  name                = "${var.virtual_machine_name}-${count.index + 1}"
  resource_group_name = azurerm_resource_group.tf-rg.name
  location            = azurerm_resource_group.tf-rg.location
  size                = var.virtual_machine_size
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password

  network_interface_ids = [
    azurerm_network_interface.tf-nic[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }
}

# Install IIS, Chrome, configure firewall, and create webpage on each Windows VM
resource "azurerm_virtual_machine_extension" "tf-iis" {
  count                = var.windows_vm_count
  name                 = "install-iis"
  virtual_machine_id   = azurerm_windows_virtual_machine.tf-windows[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -Command \"Start-Sleep -Seconds 60; New-NetFirewallRule -DisplayName 'Allow ICMPv4-In' -Protocol ICMPv4; Install-WindowsFeature -name Web-Server -IncludeManagementTools; Get-ChildItem C:\\inetpub\\wwwroot\\ | Remove-Item -Force -ErrorAction SilentlyContinue; $meta = Invoke-RestMethod -Headers @{'Metadata'='true'} -Uri 'http://169.254.169.254/metadata/instance?api-version=2021-02-01'; $location = $meta.compute.location; $dnsName = $($env:computername.ToLower() + '.' + $location + '.cloudapp.azure.com'); $html = '<html><body style=font-family:Arial;padding:20px><h1>Hello World from ' + $env:computername + '</h1><p><b>VM Name:</b> ' + $env:computername + '</p><p><b>DNS Name:</b> ' + $dnsName + '</p></body></html>'; Set-Content -Path 'C:\\inetpub\\wwwroot\\iisstart.htm' -Value $html; $LocalTempDir = $env:TEMP; $ChromeInstaller = 'ChromeInstaller.exe'; (New-Object System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', \\\"$LocalTempDir\\\\$ChromeInstaller\\\"); & \\\"$LocalTempDir\\\\$ChromeInstaller\\\" /silent /install; $Process2Monitor = 'ChromeInstaller'; Do { $ProcessesFound = Get-Process | Where-Object { $Process2Monitor -contains $_.Name } | Select-Object -ExpandProperty Name; If ($ProcessesFound) { Start-Sleep -Seconds 2 } else { Remove-Item \\\"$LocalTempDir\\\\$ChromeInstaller\\\" -ErrorAction SilentlyContinue } } Until (!$ProcessesFound)\""
  })

  depends_on = [azurerm_windows_virtual_machine.tf-windows]
}

# ─── Ubuntu Virtual Machines ─────────────────────────────────────────────────
# count is driven by var.ubuntu_vm_count (default 1 — change to 2 or 3 in tfvars)
# Ubuntu VMs live in tf-ubuntu-subnet (separate from Windows subnet)

resource "azurerm_linux_virtual_machine" "tf-ubuntu" {
  count               = var.ubuntu_vm_count
  name                = "${var.ubuntu_vm_name}-${count.index + 1}"
  resource_group_name = azurerm_resource_group.tf-rg.name
  location            = azurerm_resource_group.tf-rg.location
  size                = var.ubuntu_vm_size
  admin_username      = var.ubuntu_vm_admin_username
  admin_password      = var.ubuntu_vm_admin_password

  # Set to false to allow password authentication (true = SSH key only)
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.tf-ubuntu-nic[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.ubuntu_vm_image_publisher
    offer     = var.ubuntu_vm_image_offer
    sku       = var.ubuntu_vm_image_sku
    version   = var.ubuntu_vm_image_version
  }
}

# Install Apache2 and create a webpage on each Ubuntu VM
# Apache2 is the Linux equivalent of IIS — serves HTTP on port 80
resource "azurerm_virtual_machine_extension" "tf-apache" {
  count                = var.ubuntu_vm_count
  name                 = "install-apache"
  virtual_machine_id   = azurerm_linux_virtual_machine.tf-ubuntu[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = jsonencode({
    commandToExecute = "export DEBIAN_FRONTEND=noninteractive; apt-get update -y; apt-get install -y apache2; systemctl enable apache2; systemctl start apache2; HN=$(hostname); LOCATION=$(curl -sf -H 'Metadata:true' 'http://169.254.169.254/metadata/instance/compute/location?api-version=2021-02-01&format=text'); DNS=$(echo $HN | tr '[:upper:]' '[:lower:]').$LOCATION.cloudapp.azure.com; echo \"<html><body style=font-family:Arial;padding:20px><h1>Hello World from $HN</h1><p><b>VM Name:</b> $HN</p><p><b>DNS Name:</b> $DNS</p><p><b>OS:</b> Ubuntu 22.04 LTS</p><p><b>Web Server:</b> Apache2</p></body></html>\" > /var/www/html/index.html"
  })

  depends_on = [azurerm_linux_virtual_machine.tf-ubuntu]
}
