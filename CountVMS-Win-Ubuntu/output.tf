# ─── Windows VM Outputs ───────────────────────────────────────────────────────

output "windows_vm_names" {
  description = "Names of all Windows VMs"
  value       = azurerm_windows_virtual_machine.tf-windows[*].name
}

output "windows_vm_public_ips" {
  description = "Public IP addresses of all Windows VMs"
  value       = azurerm_public_ip.tf-pip[*].ip_address
}

output "windows_vm_dns_names" {
  description = "DNS names of all Windows VMs"
  value       = azurerm_public_ip.tf-pip[*].fqdn
}

# ─── Ubuntu VM Outputs ────────────────────────────────────────────────────────

output "ubuntu_vm_names" {
  description = "Names of all Ubuntu VMs"
  value       = azurerm_linux_virtual_machine.tf-ubuntu[*].name
}

output "ubuntu_vm_public_ips" {
  description = "Public IP addresses of all Ubuntu VMs"
  value       = azurerm_public_ip.tf-ubuntu-pip[*].ip_address
}

output "ubuntu_vm_dns_names" {
  description = "DNS names of all Ubuntu VMs"
  value       = azurerm_public_ip.tf-ubuntu-pip[*].fqdn
}
