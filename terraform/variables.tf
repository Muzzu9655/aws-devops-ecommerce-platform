# ------------------------
# General Variables
# ------------------------
variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

# ------------------------
# VPC Variables
# ------------------------
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_a_cidr" {
  default = "10.0.1.0/24"
}

variable "public_subnet_b_cidr" {
  default = "10.0.2.0/24"
}

variable "private_subnet_a_cidr" {
  default = "10.0.3.0/24"
}

variable "private_subnet_b_cidr" {
  default = "10.0.4.0/24"
}

# ------------------------
# RDS Variables
# ------------------------
variable "db_name" {
  default = "ordersdb"
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  default = "Admin12345"
}

variable "db_instance_class" {
  default = "db.t3.micro"
}

# ------------------------
# EKS Variables
# ------------------------
variable "cluster_name" {
  default = "ecommerce-cluster"
}
