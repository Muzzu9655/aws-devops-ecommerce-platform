# ------------------------
# AWS Provider
# ------------------------
provider "aws" {
  region = "us-east-1" # change to your nearest region
}

# ------------------------
# VPC with 2 Public + 2 Private Subnets
# ------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "devops-vpc" }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = { Name = "public-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = { Name = "public-b" }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "private-a" }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = { Name = "private-b" }
}

# ------------------------
# S3 Bucket for Product Images
# ------------------------
resource "aws_s3_bucket" "product_images" {
  bucket = "ecommerce-product-images-${random_id.bucket_id.hex}"
  acl    = "private"
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

# ------------------------
# RDS MySQL for Orders
# ------------------------
resource "aws_db_instance" "mysql" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  name                 = "ordersdb"
  username             = "admin"
  password             = "Admin12345"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  vpc_security_group_ids = []
  publicly_accessible  = false
}

# ------------------------
# EKS Cluster
# ------------------------
resource "aws_eks_cluster" "main" {
  name     = "ecommerce-cluster"
  role_arn = "" # will add IAM role later
  vpc_config {
    subnet_ids = [
      aws_subnet.public_a.id,
      aws_subnet.public_b.id,
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]
  }
}
