# Create a Resource Group if it doesn’t exist
resource "azurerm_resource_group" "demo" {
  name     = "${var.prefix}_rg"
  location = "${var.location}"

  tags = {
    Environment = "${var.env}"
    Department = "${var.department}"
  }
}

# Creates Shared Image Gallery
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/shared_image_gallery
resource "azurerm_shared_image_gallery" "demo" {
  name                = "${var.prefix}_sig"
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  description         = "Shared images"

  tags = {
    Environment = "${var.env}"
    Department = "${var.department}"
  }
}

resource "azurerm_shared_image" "cube-ubuntu-base" {
  name                = "cube-ubuntu-base"
  gallery_name        = azurerm_shared_image_gallery.demo.name
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  os_type             = "Linux"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "${var.prefix}"
    offer     = "cube_ubuntu_base"
    sku       = "${var.prefix}_cube_ubuntu_base"
  }

  tags = {
    Environment = "${var.env}"
    Department = "${var.department}"
  }
}

resource "azurerm_shared_image" "cube-ubuntu-myapp" {
  name                = "cube-ubuntu-myapp"
  gallery_name        = azurerm_shared_image_gallery.demo.name
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  os_type             = "Linux"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "${var.prefix}"
    offer     = "cube_myapp"
    sku       = "${var.prefix}_cube_myapp"
  }

  tags = {
    Environment = "${var.env}"
    Department = "${var.department}"
  }
}
