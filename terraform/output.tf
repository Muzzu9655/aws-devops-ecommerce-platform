output "s3_bucket_name" {
  description = "S3 bucket for storing product images/assets"
  value       = aws_s3_bucket.ecommerce_assets.id
}

output "dynamodb_table_name" {
  description = "DynamoDB table used for product storage"
  value       = aws_dynamodb_table.products.name
}

output "lambda_function_name" {
  description = "Lambda function handling backend logic"
  value       = aws_lambda_function.backend.function_name
}

output "api_gateway_endpoint" {
  description = "Public endpoint of the API Gateway"
  value       = aws_apigatewayv2_stage.dev.invoke_url
}
