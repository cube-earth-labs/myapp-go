resource "azurerm_resource_group" "myresourcegroup" {
  name     = "${var.prefix}-myapp"
  location = var.location

  tags = {
    environment = var.environment
  }
}