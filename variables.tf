# Define the AWS region for deployment
variable "region" {
  type        = string
  description = "The AWS region to deploy into"
  default     = "us-east-1"
}

# Define the CIDR block for the VPC
variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# Define the path to the public SSH key
variable "public_key_path" {
  type        = string
  description = "Path to the public SSH key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  type        = string
  description = "Path to the private SSH key"
  default     = "~/.ssh/id_rsa"
}

# Define the AMI ID for EC2 instances
variable "ami_id" {
  type        = string
  description = "The AMI ID to use for EC2 instances"
  default     = "ami-053a45fff0a704a47"
}

# Define the EC2 instance type
variable "instance_type" {
  type        = string
  description = "The type of EC2 instance"
  default     = "t2.micro"
}

# Define the number of availability zones
variable "availability_zone_count" {
  type        = number
  description = "Number of availability zones"
  default     = 3
}

