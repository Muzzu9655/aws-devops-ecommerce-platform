variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for storing static assets"
  type        = string
  default     = "muzamil-ecommerce-assets"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table for products and carts"
  type        = string
  default     = "ecommerce-products"
}

variable "lambda_zip_path" {
  description = "Path to Lambda deployment package zip file"
  type        = string
  default     = "lambda_function_payload.zip"
}

variable "lambda_role_arn" {
  description = "IAM Role ARN for Lambda execution"
  type        = string
  default     = "arn:aws:iam::123456789012:role/lambda_exec_role"
}
