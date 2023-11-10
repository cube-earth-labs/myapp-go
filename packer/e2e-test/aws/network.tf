resource "aws_vpc" "myapp" {
  cidr_block           = var.address_space
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.prefix}-vpc-${var.region}"
    environment = var.environment
  }
}

resource "aws_subnet" "myapp" {
  vpc_id     = aws_vpc.myapp.id
  cidr_block = var.subnet_prefix

  tags = {
    Name = "${var.prefix}-subnet"
  }
}

resource "aws_security_group" "myapp" {
  name = "${var.prefix}-security-group"

  vpc_id = aws_vpc.myapp.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.prefix}-security-group"
  }
}

resource "aws_internet_gateway" "myapp" {
  vpc_id = aws_vpc.myapp.id

  tags = {
    Name = "${var.prefix}-internet-gateway"
  }
}

resource "aws_route_table" "myapp" {
  vpc_id = aws_vpc.myapp.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp.id
  }
  tags = {
    environment = var.environment
    application = "MyApp"
    owner       = "Eric"
    costcenter  = "123"
  }
}

resource "aws_route_table_association" "myapp" {
  subnet_id      = aws_subnet.myapp.id
  route_table_id = aws_route_table.myapp.id
}

resource "aws_eip" "myapp" {
  instance = aws_instance.myapp.id
  domain   = "vpc"
}

resource "aws_eip_association" "myapp" {
  instance_id   = aws_instance.myapp.id
  allocation_id = aws_eip.myapp.id
}
