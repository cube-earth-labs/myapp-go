# Non HCP Packer AMI lookup
# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical
# }
#

data "hcp_packer_iteration" "myapp" {
  bucket_name = "cube-ubuntu-myapp"
  channel     = var.environment
}

data "hcp_packer_image" "myapp" {
  bucket_name    = data.hcp_packer_iteration.myapp.bucket_name
  cloud_provider = "aws"
  iteration_id   = var.iteration_id == null ? data.hcp_packer_iteration.myapp.ulid : var.iteration_id
  region         = var.region
}

resource "aws_instance" "myapp" {
  ami = data.hcp_packer_image.myapp.cloud_image_id # Retrieving from HCP Packer registry
  #ami                         = data.aws_ami.ubuntu.id   # Retrieving AMI ID from AWS data filter
  #ami                         = "ami-09295ca9d73f1c048"  # Direct AMI ID assignment
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.myapp.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.myapp.id
  vpc_security_group_ids      = [aws_security_group.myapp.id]
  user_data                   = file("${path.module}/scripts/userdata-server.sh")
  tags = {
    Name               = "${var.prefix}-myapp-${var.environment}"
    Department         = "Development"
    HCP-Image-Channel  = data.hcp_packer_image.myapp.channel
    HCP-Iteration-ID   = data.hcp_packer_iteration.myapp.ulid
    HCP-Image-Version  = data.hcp_packer_iteration.myapp.incremental_version
    HCP-Image-Creation = data.hcp_packer_iteration.myapp.created_at
  }

  lifecycle {
    postcondition {
      condition     = self.ami == data.hcp_packer_image.myapp.cloud_image_id
      error_message = "Please redeploy to update to image ID: ${data.hcp_packer_image.myapp.cloud_image_id}."
    }
  }
}
