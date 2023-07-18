# HashiCorp Solution Series

## Description
This repository contains the code used for HasihCorp Solution Series - Part 1:  Provision Infrastructure with HCP Packer.

## Documentation

### Pre-Req Steps

#### Azure Image Galleries

These steps must be completed first to provision the Shared Machine Image Gallery we will publish images to.

- cd prereq/0-terraform-azure-prep
- cp terraform.auto.tfvars.example terraform.auto.tfvars
- Update terraform.auto.tfvars
- terraform apply

#### Base Images

Initial base images will be built using Ubuntu 22.04 as a base.

- cd prereq/1-packer-base-image
- cp packer.auto.pkrvars.hcl.template packer.auto.pkrvars.hcl
- Update packer.auto.pkrvars.hcl
- packer init -upgrade .
- packer build .
