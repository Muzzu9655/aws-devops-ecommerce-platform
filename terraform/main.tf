##########################################
# Providers & Versions
##########################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1" # Mumbai
}

resource "random_id" "suffix" {
  byte_length = 4
}

##########################################
# Networking
##########################################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "ecom-vpc" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "ecom-gw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = { Name = "ecom-public-subnet" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "ecom-public-rt" }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

##########################################
# S3 Bucket
##########################################
resource "aws_s3_bucket" "product_images" {
  bucket = "ecommerce-product-images-${random_id.suffix.hex}"
  tags   = { Name = "ecom-product-images" }
}

resource "aws_s3_bucket_acl" "product_images_acl" {
  bucket = aws_s3_bucket.product_images.id
  acl    = "private"
}

##########################################
# RDS MySQL
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
  db_name                = "ecomdb"
  username               = "admin"
  password               = "Admin12345"
  db_subnet_group_name   = aws_db_subnet_group.db.name
  skip_final_snapshot    = true
  publicly_accessible    = true
}

##########################################
# EKS Cluster + Node Group
##########################################
resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_cluster" "ecom" {
  name     = "ecom-cluster-${random_id.suffix.hex}"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = [aws_subnet.public.id]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# Node Group Role
resource "aws_iam_role" "eks_nodes" {
  name = "eks-nodes-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_eks_node_group" "ecom_nodes" {
  cluster_name    = aws_eks_cluster.ecom.name
  node_group_name = "ecom-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [aws_subnet.public.id]
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.eks_cni,
    aws_iam_role_policy_attachment.ec2_container_registry
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
