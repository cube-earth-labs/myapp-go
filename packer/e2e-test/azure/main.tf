data "hcp_packer_iteration" "myapp" {
  bucket_name = "cube-ubuntu-myapp"
  channel     = var.environment
}

data "hcp_packer_image" "myapp" {
  bucket_name    = data.hcp_packer_iteration.myapp.bucket_name
  cloud_provider = "azure"
  iteration_id   = var.iteration_id == null ? data.hcp_packer_iteration.myapp.ulid : var.iteration_id
  region         = var.location
}

resource "azurerm_virtual_machine" "myapp" {
  name                = "${var.prefix}-myapp"
  location            = var.location
  resource_group_name = azurerm_resource_group.myresourcegroup.name
  vm_size             = var.vm_size

  network_interface_ids         = [azurerm_network_interface.myapp-nic.id]
  delete_os_disk_on_termination = "true"

  tags = {
    Billable           = "1234567"
    Department         = "Development"
    HCP-Image-Channel  = data.hcp_packer_image.myapp.channel
    HCP-Iteration-ID   = data.hcp_packer_iteration.myapp.ulid
    HCP-Image-Version  = data.hcp_packer_iteration.myapp.incremental_version
    HCP-Image-Creation = data.hcp_packer_iteration.myapp.created_at
  }

  storage_image_reference {
    id = data.hcp_packer_image.myapp.cloud_image_id
  }

  storage_os_disk {
    name              = "${var.prefix}-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = var.prefix
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = file("${path.module}/scripts/userdata-server.sh")
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  # Added to allow destroy to work correctly.
  depends_on = [azurerm_network_interface_security_group_association.myapp-nic-sg-ass]
}
