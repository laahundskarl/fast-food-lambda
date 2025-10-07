# ===========================
# LAMBDA INFRASTRUCTURE OUTPUTS
# ===========================

# Lambda Function Outputs
output "lambda_function_name" {
  description = "Nome da função Lambda"
  value       = aws_lambda_function.auth_lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN da função Lambda"
  value       = aws_lambda_function.auth_lambda.arn
}

output "lambda_function_invoke_arn" {
  description = "ARN de invocação da função Lambda"
  value       = aws_lambda_function.auth_lambda.invoke_arn
}

output "lambda_function_version" {
  description = "Versão da função Lambda"
  value       = aws_lambda_function.auth_lambda.version
}

# IAM Outputs
output "lambda_role_arn" {
  description = "ARN da role IAM da Lambda"
  value       = aws_iam_role.lambda_auth_role.arn
}

output "lambda_role_name" {
  description = "Nome da role IAM da Lambda"
  value       = aws_iam_role.lambda_auth_role.name
}

# API Gateway Outputs
output "api_gateway_id" {
  description = "ID da REST API do API Gateway"
  value       = aws_api_gateway_rest_api.fast_food_lambda_api.id
}

output "api_gateway_name" {
  description = "Nome da REST API do API Gateway"
  value       = aws_api_gateway_rest_api.fast_food_lambda_api.name
}

output "api_gateway_execution_arn" {
  description = "ARN de execução do API Gateway"
  value       = aws_api_gateway_rest_api.fast_food_lambda_api.execution_arn
}

output "api_gateway_url" {
  description = "URL do endpoint de autenticação"
  value       = "${aws_api_gateway_deployment.fast_food_lambda_api_deployment.invoke_url}/auth"
}

output "api_gateway_stage_name" {
  description = "Nome do stage do API Gateway"
  value       = aws_api_gateway_deployment.fast_food_lambda_api_deployment.stage_name
}

# CloudWatch Outputs
output "cloudwatch_log_group_name" {
  description = "Nome do grupo de logs do CloudWatch"
  value       = aws_cloudwatch_log_group.lambda_auth_logs.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN do grupo de logs do CloudWatch"
  value       = aws_cloudwatch_log_group.lambda_auth_logs.arn
}

# Environment Outputs
output "environment" {
  description = "Ambiente de deployment"
  value       = var.environment
}

output "aws_region" {
  description = "Região AWS utilizada"
  value       = var.aws_region
}

# Database Connection Info (para integração)
output "database_endpoint" {
  description = "Endpoint do banco de dados configurado"
  value       = var.database_host != "" ? var.database_host : try(data.aws_db_instance.fastfood_mysql[0].endpoint, "not-configured")
  sensitive   = false
}

# Integration Outputs (para outros repositórios)
output "lambda_auth_endpoint" {
  description = "Endpoint completo para autenticação (para integração com outros serviços)"
  value = {
    url            = "${aws_api_gateway_deployment.fast_food_lambda_api_deployment.invoke_url}/auth"
    method         = "POST"
    function_name  = aws_lambda_function.auth_lambda.function_name
    function_arn   = aws_lambda_function.auth_lambda.arn
  }
}

# Deployment Info
output "deployment_info" {
  description = "Informações de deployment"
  value = {
    timestamp      = timestamp()
    terraform_version = "1.0+"
    environment    = var.environment
    region         = var.aws_region
    lambda_runtime = var.lambda_runtime
    lambda_memory  = var.lambda_memory_size
    lambda_timeout = var.lambda_timeout
  }
}