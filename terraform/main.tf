terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1️⃣ S3 bucket for static assets / product images
resource "aws_s3_bucket" "ecommerce_assets" {
  bucket = var.s3_bucket_name

  tags = {
    Project = "AWS DevOps E-Commerce"
    Environment = "Demo"
  }
}

# 2️⃣ DynamoDB table for storing product/cart data
resource "aws_dynamodb_table" "products" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key     = "product_id"

  attribute {
    name = "product_id"
    type = "S"
  }

  tags = {
    Project = "AWS DevOps E-Commerce"
    Environment = "Demo"
  }
}

# 3️⃣ Lambda function for backend logic
resource "aws_lambda_function" "backend" {
  function_name = "ecommerce-backend"
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  filename      = var.lambda_zip_path

  role = var.lambda_role_arn
}

# 4️⃣ API Gateway to expose Lambda function
resource "aws_apigatewayv2_api" "http_api" {
  name          = "ecommerce-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.backend.invoke_arn
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /products"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "dev"
  auto_deploy = true
}
