AWS DevOps E-Commerce Platform – Terraform IaC

Project Overview
This project provisions an E-commerce platform infrastructure on AWS using Terraform (Infrastructure as Code).

The architecture leverages serverless and free-tier AWS services to ensure low cost while showcasing DevOps & Cloud Engineering skills.

Key Highlights:
- Fully automated infrastructure using Terraform
- Serverless-first approach to avoid unnecessary billing
- Modular, scalable design suitable for real e-commerce workloads

------------------------------------------------------------

Architecture

Services Used:
- Amazon S3 -> Store static assets (product images, frontend)
- AWS DynamoDB -> NoSQL database for products & cart info
- AWS Lambda -> Serverless backend for handling API requests
- Amazon API Gateway -> Public endpoint for the e-commerce API

Flow:
Client -> API Gateway -> Lambda -> DynamoDB
                        |
                        -> S3 Bucket (Static Assets)

Designed for free-tier usage to prevent unnecessary AWS costs.

------------------------------------------------------------

# Project Structure
# aws-devops-ecommerce-platform/Terraform
- main.tf - Terraform Configuration
- variables.tf - Input variables 
- outputs.tf  - Key outputs
- README.md      - Project documentation
-:.gitignore     - Ignore Terraform state & cache

------------------------------------------------------------

# How to Deploy

Note: Deployment is optional. This project can be showcased without live infra to avoid AWS costs.

1) Initialize Terraform
terraform init

2) Validate and Plan
terraform plan

3) Deploy (Optional)
terraform apply

4) Destroy to Avoid Billing
terraform destroy

------------------------------------------------------------

# Outputs
After applying, Terraform will display:
- S3 bucket name for assets
- DynamoDB table name
- Lambda function name
- API Gateway endpoint URL

------------------------------------------------------------

# Cost & Deployment Notes
- This architecture is free-tier friendly (serverless-first)
- Do not keep resources running if you want to avoid charges
- terraform destroy removes all resources after testing

------------------------------------------------------------

# Future Enhancements
- Add CI/CD pipeline using GitHub Actions
- Containerize backend with AWS Fargate (ECS)
- Add CloudFront CDN for global performance
