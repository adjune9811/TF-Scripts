# 6 resource create vm

resource "azurerm_windows_virtual_machine" "tf-windows" {
  name                = var.virtual_machine_name
  resource_group_name = azurerm_resource_group.tf-rg.name
  location            = azurerm_resource_group.tf-rg.location
  size                = var.virtual_machine_size
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
    network_interface_ids = [
    azurerm_network_interface.tf-nic.id,
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

# Install IIS, Chrome, configure firewall, and create webpage
resource "azurerm_virtual_machine_extension" "tf-iis" {
  name                 = "install-iis"
  virtual_machine_id   = azurerm_windows_virtual_machine.tf-windows.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -Command \"Start-Sleep -Seconds 60; New-NetFirewallRule -DisplayName 'Allow ICMPv4-In' -Protocol ICMPv4; Install-WindowsFeature -name Web-Server -IncludeManagementTools; Get-ChildItem C:\\inetpub\\wwwroot\\ | Remove-Item -Force -ErrorAction SilentlyContinue; $meta = Invoke-RestMethod -Headers @{'Metadata'='true'} -Uri 'http://169.254.169.254/metadata/instance?api-version=2021-02-01'; $location = $meta.compute.location; $dnsName = $($env:computername.ToLower() + '.' + $location + '.cloudapp.azure.com'); $html = '<html><body style=font-family:Arial;padding:20px><h1>Hello World from ' + $env:computername + '</h1><p><b>VM Name:</b> ' + $env:computername + '</p><p><b>DNS Name:</b> ' + $dnsName + '</p></body></html>'; Set-Content -Path 'C:\\inetpub\\wwwroot\\iisstart.htm' -Value $html; $LocalTempDir = $env:TEMP; $ChromeInstaller = 'ChromeInstaller.exe'; (New-Object System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', \\\"$LocalTempDir\\\\$ChromeInstaller\\\"); & \\\"$LocalTempDir\\\\$ChromeInstaller\\\" /silent /install; $Process2Monitor = 'ChromeInstaller'; Do { $ProcessesFound = Get-Process | Where-Object { $Process2Monitor -contains $_.Name } | Select-Object -ExpandProperty Name; If ($ProcessesFound) { Start-Sleep -Seconds 2 } else { Remove-Item \\\"$LocalTempDir\\\\$ChromeInstaller\\\" -ErrorAction SilentlyContinue } } Until (!$ProcessesFound)\""
  })

  depends_on = [azurerm_windows_virtual_machine.tf-windows]
}