#---------------------------------------------------------------------------------------
# Packer Plugins
#---------------------------------------------------------------------------------------
packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/amazon"
    }
    azure = {
      version = "~>1.0"
      source  = "github.com/hashicorp/azure"
    }

  }
}

#---------------------------------------------------------------------------------------
# Common Image Metadata
#---------------------------------------------------------------------------------------
variable "hcp_base_bucket" {
  default = "cube-ubuntu-base"
}

variable "image_name" {
  default = "cube-ubuntu-base"
}

variable "version" {
  default = "1.0.0"
}

#--------------------------------------------------
# AWS Image Config and Definition
#--------------------------------------------------
variable "aws_region" {
  default = "us-east-1"
}

locals {
  timestamp  = regex_replace(timestamp(), "[- TZ:]", "")
  #  image_name = "${var.prefix}-ubuntu22-${local.timestamp}"
  image_name = "cube-ubuntu-base"
}

data "amazon-ami" "aws_base" {
  region = var.aws_region
  filters = {
    name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "cube-ubuntu-base" {
  region         = var.aws_region
  source_ami     = data.amazon-ami.aws_base.id
  instance_type  = "t2.small"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false
  ami_name       = "packer_aws_{{timestamp}}_${var.image_name}_v${var.version}"
}

source "azure-arm" "cube-ubuntu-base" {
  os_type                   = "Linux"
  build_resource_group_name = var.az_resource_group
  vm_size                   = "Standard_B2s"

  # Source image
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-jammy"
  image_sku       = "22_04-lts-gen2"
  image_version   = "latest"

  # Destination image
  managed_image_name                = local.image_name
  managed_image_resource_group_name = var.az_resource_group
  shared_image_gallery_destination {
    subscription         = var.az_subscription_id
    resource_group       = var.az_resource_group
    gallery_name         = var.az_image_gallery
    image_name           = "cube-ubuntu-base"
    image_version        = formatdate("YYYY.MMDD.hhmm", timestamp())
    replication_regions  = [var.az_region]
    storage_account_type = "Standard_LRS"
  }

  azure_tags = {
    owner      = var.owner
    department = var.department
    build-time = local.timestamp
  }
  use_azure_cli_auth = true
}


#---------------------------------------------------------------------------------------
# Common Build Definition
#---------------------------------------------------------------------------------------
build {

  hcp_packer_registry {
    bucket_name = var.hcp_base_bucket
    description = <<EOT
This is the base Ubuntu image
    EOT
    bucket_labels = {
      "owner"          = var.owner
      "department"     = var.department
      "os"             = "Ubuntu"
      "ubuntu-version" = "22.04"
      "image-name"     = var.image_name
    }

    build_labels = {
      "build-time"        = local.timestamp
      "build-source"      = basename(path.cwd)
      "cube-ubuntu-base-version" = var.version
    }
  }

  sources = [
    "sources.amazon-ebs.cube-ubuntu-base",
    "source.azure-arm.cube-ubuntu-base"
  ]

  # Make sure cloud-init has finished
  provisioner "shell" {
    inline = ["echo 'Wait for cloud-init...' && /usr/bin/cloud-init status --wait"]
  }

  provisioner "shell" {
    script          = "${path.root}/update.sh"
    execute_command = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
  }

  provisioner "shell" {
    inline = [
      "sleep 1"
    ]
  }

}
