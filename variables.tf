# Change these variables to suit your deployment.

variable "region" {
  description = "The AWS region to deploy into"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_key_path" {
  description = "Path to the public SSH key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "ami_id" {
  description = "The AMI ID to use for EC2 instances"
  default     = "ami-007868005aea67c54"  # Amazon Linux 2 AMI in us-east-1 (Free tier)
}

variable "instance_type" {
  description = "The type of EC2 instance"
  default     = "t2.micro"
}

variable "availability_zone_count" {
  description = "Number of availability zones"
  default     = 3
}
