variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

# Lambda variables
variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "fast-food-auth"
}

variable "lambda_handler" {
  description = "Lambda function handler"
  type        = string
  default     = "index.handler"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "nodejs18.x"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 256
}

variable "lambda_filename" {
  description = "Path to the Lambda deployment package"
  type        = string
  default     = "../lambda-deployment.zip"
}

# API Gateway variables
variable "api_gateway_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "fast-food-lambda-api"
}

variable "api_gateway_stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "prod"
}

# Database variables (for Lambda environment)
variable "database_host" {
  description = "Database host"
  type        = string
  default     = ""
}

variable "database_port" {
  description = "Database port"
  type        = number
  default     = 3306
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "fastfood"
}

variable "database_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "database_password" {
  description = "Database password"
  type        = string
  default     = "admin123"
  sensitive   = true
}

# JWT variables
variable "jwt_secret" {
  description = "JWT secret key"
  type        = string
  default     = "fast-food-secret-key-2024"
  sensitive   = true
}