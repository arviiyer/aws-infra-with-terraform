terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main-internet-gateway"
  }
}

# Data source to get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Create Public Subnets
resource "aws_subnet" "public_subnet" {
  count                  = var.availability_zone_count
  vpc_id                 = aws_vpc.main_vpc.id
  cidr_block             = cidrsubnet(aws_vpc.main_vpc.cidr_block, 4, count.index)
  map_public_ip_on_launch = true
  availability_zone      = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# Create Private Subnets
resource "aws_subnet" "private_subnet" {
  count                  = var.availability_zone_count
  vpc_id                 = aws_vpc.main_vpc.id
  cidr_block             = cidrsubnet(aws_vpc.main_vpc.cidr_block, 4, 3 + count.index)
  map_public_ip_on_launch = false
  availability_zone      = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# Create Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "public-route-table"
  }
}

# Associate Route Table with Public Subnets
resource "aws_route_table_association" "public_route_table_association" {
  count          = var.availability_zone_count
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

# Create NAT Gateway (One per AZ)
resource "aws_nat_gateway" "nat_gateway" {
  count         = var.availability_zone_count
  allocation_id = element(aws_eip.elastic_ip.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  tags = {
    Name = "nat-gateway-${count.index + 1}"
  }
}

# Allocate Elastic IPs for NAT Gateway
resource "aws_eip" "elastic_ip" {
  count = var.availability_zone_count
  vpc   = true
  tags = {
    Name = "nat-gateway-eip-${count.index + 1}"
  }
}

# Create Route Table for Private Subnets
resource "aws_route_table" "private_route_table" {
  count = var.availability_zone_count
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block    = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gateway.*.id, count.index)
  }
  tags = {
    Name = "private-route-table-${count.index + 1}"
  }
}

# Associate Private Subnets with Private Route Tables
resource "aws_route_table_association" "private_route_table_association" {
  count          = var.availability_zone_count
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private_route_table.*.id, count.index)
}

# Create Security Group for Bastion Host
resource "aws_security_group" "bastion_security_group" {
  vpc_id      = aws_vpc.main_vpc.id
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

# Create Security Group for EC2 Instances in Private Subnets
resource "aws_security_group" "private_security_group" {
  vpc_id      = aws_vpc.main_vpc.id
  description = "Allow HTTP and SSH from bastion host and outbound access to the Internet via NAT"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_security_group.id]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-ec2-sg"
  }
}

# Create Security Group for Load Balancer
resource "aws_security_group" "alb_security_group" {
  vpc_id      = aws_vpc.main_vpc.id
  description = "Allow HTTP inbound traffic to the load balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# Add SSH Key Pair 
resource "aws_key_pair" "generated_key" {
  key_name   = "terraform-generated-key"
  public_key = file(var.public_key_path)  # Path to your public key
}

# Create Bastion Host in Public Subnet
resource "aws_instance" "bastion_host" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  security_groups = [aws_security_group.bastion_security_group.id]
  key_name      = aws_key_pair.generated_key.key_name  # Use the Terraform-created key

  tags = {
    Name = "bastion-host"
  }
}

# Create EC2 Instances in Private Subnets with Web Server
resource "aws_instance" "private_instances" {
  count         = var.availability_zone_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(aws_subnet.private_subnet.*.id, count.index)
  security_groups = [aws_security_group.private_security_group.id]
  key_name      = aws_key_pair.generated_key.key_name  # Use the Terraform-created key

  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y httpd
                INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
                echo "Hello World from instance $INSTANCE_ID" > /var/www/html/index.html
                systemctl start httpd
                systemctl enable httpd
                EOF

  tags = {
    Name = "private-ec2-${count.index + 1}"
  }
}

# Create an Application Load Balancer
resource "aws_lb" "application_load_balancer" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = aws_subnet.public_subnet.*.id

  tags = {
    Name = "web-alb"
  }
}

# Create a Target Group for the EC2 Instances
resource "aws_lb_target_group" "target_group" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }

  tags = {
    Name = "web-tg"
  }
}

# Attach EC2 Instances to the Target Group
resource "aws_lb_target_group_attachment" "target_group_attachment" {
  count            = var.availability_zone_count
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.private_instances.*.id[count.index]
  port             = 80
}

# Create a Listener for the Load Balancer
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}
