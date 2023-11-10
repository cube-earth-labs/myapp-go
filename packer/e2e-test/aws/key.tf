resource "tls_private_key" "myapp" {
  algorithm = "RSA"
}

resource "random_id" "app-server-id" {
  prefix      = "${var.prefix}-myapp-"
  byte_length = 8
}

locals {
  private_key_filename = "${random_id.app-server-id.dec}-ssh-key.pem"
}

resource "aws_key_pair" "myapp" {
  key_name   = local.private_key_filename
  public_key = tls_private_key.myapp.public_key_openssh
  tags = {
    environment = var.environment
    application = "MyApp"
    owner       = "Eric"
    costcenter  = "123"
  }
}

# resource "null_resource" "myapp" {
#   provisioner "local-exec" {
#     command = "echo '${tls_private_key.myapp.private_key_pem}' > ~/.ssh/${var.prefix}-${var.environment}.pem && chmod 600 ~/.ssh/${var.prefix}-${var.environment}.pem"
#   }
# }
