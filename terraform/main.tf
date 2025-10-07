# ===========================
# LAMBDA AUTHENTICATION INFRASTRUCTURE
# ===========================

# Data source para obter RDS endpoint (se existir)
data "aws_db_instance" "fastfood_mysql" {
  count                 = 1
  db_instance_identifier = "fastfood-db"
}

# Data source para VPC padrão
data "aws_vpc" "existing" {
  default = true
}

# Subnets específicas para Lambda (se necessário VPC deployment)
data "aws_subnet" "fastfood_subnet_1a" {
  count = 1
  id    = "subnet-08d34ed68511f3917"  # us-east-1a
}

data "aws_subnet" "fastfood_subnet_1b" {
  count = 1
  id    = "subnet-07fe020cefc4bd241"  # us-east-1b
}

# ===========================
# IAM ROLE FOR LAMBDA
# ===========================

resource "aws_iam_role" "lambda_auth_role" {
  name = "fast-food-lambda-auth-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Component   = "serverless"
    Project     = "fast-food"
  }
}

# IAM Policy para logs básicos
resource "aws_iam_role_policy_attachment" "lambda_auth_basic" {
  role       = aws_iam_role.lambda_auth_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# IAM Policy para VPC access (se necessário)
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  count      = var.database_host != "" ? 1 : 0
  role       = aws_iam_role.lambda_auth_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# IAM Policy específica para RDS access
resource "aws_iam_role_policy" "lambda_rds_policy" {
  name = "fast-food-lambda-rds-policy"
  role = aws_iam_role.lambda_auth_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters"
        ]
        Resource = "*"
      }
    ]
  })
}

# ===========================
# LAMBDA FUNCTION
# ===========================

resource "aws_lambda_function" "auth_lambda" {
  function_name = var.lambda_function_name
  role         = aws_iam_role.lambda_auth_role.arn
  handler      = var.lambda_handler
  runtime      = var.lambda_runtime
  timeout      = var.lambda_timeout
  memory_size  = var.lambda_memory_size

  filename         = var.lambda_filename
  source_code_hash = filebase64sha256(var.lambda_filename)

  environment {
    variables = {
      NODE_ENV = var.environment
      JWT_SECRET = var.jwt_secret
      DATABASE_URL = var.database_host != "" ? "mysql://${var.database_username}:${var.database_password}@${var.database_host}:${var.database_port}/${var.database_name}?allowPublicKeyRetrieval=true" : "mysql://${var.database_username}:${var.database_password}@${try(data.aws_db_instance.fastfood_mysql[0].endpoint, "localhost")}:${var.database_port}/${var.database_name}?allowPublicKeyRetrieval=true"
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_auth_basic]

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Component   = "serverless"
    Project     = "fast-food"
  }
}

# ===========================
# CLOUDWATCH LOG GROUP
# ===========================

resource "aws_cloudwatch_log_group" "lambda_auth_logs" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 7

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Component   = "monitoring"
    Project     = "fast-food"
  }
}

# ===========================
# API GATEWAY
# ===========================

resource "aws_api_gateway_rest_api" "fast_food_lambda_api" {
  name = var.api_gateway_name

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Component   = "api-gateway"
    Project     = "fast-food"
  }
}

# API Gateway Resource for /auth
resource "aws_api_gateway_resource" "auth_resource" {
  rest_api_id = aws_api_gateway_rest_api.fast_food_lambda_api.id
  parent_id   = aws_api_gateway_rest_api.fast_food_lambda_api.root_resource_id
  path_part   = "auth"
}

# API Gateway Method POST /auth
resource "aws_api_gateway_method" "auth_post" {
  rest_api_id   = aws_api_gateway_rest_api.fast_food_lambda_api.id
  resource_id   = aws_api_gateway_resource.auth_resource.id
  http_method   = "POST"
  authorization = "NONE"

  request_models = {
    "application/json" = "Empty"
  }
}

# API Gateway Integration with Lambda
resource "aws_api_gateway_integration" "auth_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.fast_food_lambda_api.id
  resource_id = aws_api_gateway_resource.auth_resource.id
  http_method = aws_api_gateway_method.auth_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.auth_lambda.invoke_arn
}

# API Gateway Method Response
resource "aws_api_gateway_method_response" "auth_post_response" {
  rest_api_id = aws_api_gateway_rest_api.fast_food_lambda_api.id
  resource_id = aws_api_gateway_resource.auth_resource.id
  http_method = aws_api_gateway_method.auth_post.http_method
  status_code = "200"

  response_headers = {
    "Access-Control-Allow-Origin"  = true
    "Access-Control-Allow-Headers" = true
    "Access-Control-Allow-Methods" = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

# API Gateway Integration Response
resource "aws_api_gateway_integration_response" "auth_lambda_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.fast_food_lambda_api.id
  resource_id = aws_api_gateway_resource.auth_resource.id
  http_method = aws_api_gateway_method.auth_post.http_method
  status_code = aws_api_gateway_method_response.auth_post_response.status_code

  response_headers = {
    "Access-Control-Allow-Origin"  = "'*'"
    "Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "Access-Control-Allow-Methods" = "'POST,OPTIONS'"
  }

  depends_on = [aws_api_gateway_integration.auth_lambda_integration]
}

# OPTIONS method for CORS
resource "aws_api_gateway_method" "auth_options" {
  rest_api_id   = aws_api_gateway_rest_api.fast_food_lambda_api.id
  resource_id   = aws_api_gateway_resource.auth_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "auth_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.fast_food_lambda_api.id
  resource_id = aws_api_gateway_resource.auth_resource.id
  http_method = aws_api_gateway_method.auth_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "auth_options_response" {
  rest_api_id = aws_api_gateway_rest_api.fast_food_lambda_api.id
  resource_id = aws_api_gateway_resource.auth_resource.id
  http_method = aws_api_gateway_method.auth_options.http_method
  status_code = "200"

  response_headers = {
    "Access-Control-Allow-Origin"  = true
    "Access-Control-Allow-Headers" = true
    "Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_integration_response" "auth_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.fast_food_lambda_api.id
  resource_id = aws_api_gateway_resource.auth_resource.id
  http_method = aws_api_gateway_method.auth_options.http_method
  status_code = "200"

  response_headers = {
    "Access-Control-Allow-Origin"  = "'*'"
    "Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "Access-Control-Allow-Methods" = "'POST,OPTIONS'"
  }

  depends_on = [aws_api_gateway_integration.auth_options_integration]
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "fast_food_lambda_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.auth_lambda_integration,
    aws_api_gateway_integration.auth_options_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.fast_food_lambda_api.id
  stage_name  = var.api_gateway_stage_name

  lifecycle {
    create_before_destroy = true
  }
}

# ===========================
# LAMBDA PERMISSIONS
# ===========================

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.fast_food_lambda_api.execution_arn}/*/*"
}