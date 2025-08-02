##########################################
# AWS Provider
##########################################
provider "aws" {
  region = "ap-south-1" # Mumbai Region
}

##########################################
# Random Suffix for Unique Resource Names
##########################################
resource "random_id" "suffix" {
  byte_length = 4
}

##########################################
# VPC and Networking
##########################################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "ecom-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "ecom-gw"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ecom-public-subnet"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "ecom-public-rt"
  }
}

# Internet Access Route
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

##########################################
# S3 Bucket for Product Images
##########################################
resource "aws_s3_bucket" "product_images" {
  bucket = "ecommerce-product-images-${random_id.suffix.hex}"
  tags = {
    Name = "ecom-product-images"
  }
}

resource "aws_s3_bucket_acl" "product_images_acl" {
  bucket = aws_s3_bucket.product_images.id
  acl    = "private"
}

##########################################
# RDS MySQL Database
##########################################
resource "aws_db_subnet_group" "db" {
  name       = "ecom-db-subnet"
  subnet_ids = [aws_subnet.public.id]
}

resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "ecomdb"         # ✅ correct argument
  username               = "admin"
  password               = "Admin12345"
  db_subnet_group_name   = aws_db_subnet_group.db.name
  skip_final_snapshot    = true
  publicly_accessible    = true

}

##########################################
# EKS Cluster (Control Plane)
##########################################
resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_cluster" "ecom" {
  name     = "ecom-cluster-${random_id.suffix.hex}"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = [aws_subnet.public.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy
  ]
}

##########################################
# Outputs
##########################################
output "s3_bucket_name" {
  value = aws_s3_bucket.product_images.bucket
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.address
}

output "eks_cluster_name" {
  value = aws_eks_cluster.ecom.name
}
