#Outputs file
output "myapp_url" {
  value = "http://${azurerm_public_ip.myapp-pip.fqdn}:8080"
}

output "myapp_ip" {
  value = "http://${azurerm_public_ip.myapp-pip.ip_address}"
}

output "health_endpoint" {
  value = "http://${azurerm_public_ip.myapp-pip.fqdn}:8080/healthz"
}
