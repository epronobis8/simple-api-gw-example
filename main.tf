provider "aws" {
  #region is set as a variable
  region = var.aws_region
}



locals {
  #you can add locals and reference them throughout such as tags and resource names
  owner               = "Erin"
  product_status_code = "200"
}
#Backend storage for our application, which is a dynamodb. 
#The database will be empty, so please add product data with productID key
resource "aws_dynamodb_table" "api-gateway-productapp-backend" {
  name           = var.dynamodb-name
  hash_key       = "productId"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "productId"
    type = "S"
  }
  tags = {
    Environment = var.envTag
    Products    = "Cars"
    IaC         = "true"
  }
}

#Creating a public REST API 
resource "aws_api_gateway_rest_api" "restAPIs" {
  name = var.api-name
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = {
    IaC         = "true"
    Environment = var.envTag
  }
}

#Product APIs
resource "aws_api_gateway_resource" "product" {
  parent_id   = aws_api_gateway_rest_api.restAPIs.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.restAPIs.id
  path_part   = "product"
}

resource "aws_api_gateway_method" "product" {
  for_each = {
    "GET"    = "GET",
    "POST"   = "POST",
    "DELETE" = "DELETE",
    OPTIONS  = "OPTIONS"
    "PATCH"  = "PATCH"
  }
  rest_api_id   = aws_api_gateway_rest_api.restAPIs.id
  resource_id   = aws_api_gateway_resource.product.id
  http_method   = each.key
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "product" {
  for_each                = aws_api_gateway_method.product
  rest_api_id             = aws_api_gateway_rest_api.restAPIs.id
  resource_id             = aws_api_gateway_resource.product.id
  http_method             = each.value.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
  request_templates = {
    "application/json" = ""
  }
  depends_on = [
    aws_api_gateway_resource.product,
    aws_api_gateway_method.product
  ]
}

resource "aws_api_gateway_method_response" "product-api-response" {
  for_each    = aws_api_gateway_method.product
  rest_api_id = aws_api_gateway_rest_api.restAPIs.id
  resource_id = aws_api_gateway_resource.product.id
  http_method = each.value.http_method
  status_code = local.product_status_code

  response_models = {
    "application/json" = "Empty"
  }
  depends_on = [
    aws_api_gateway_integration.product
  ]
}

resource "aws_api_gateway_integration_response" "product-response" {
  for_each    = aws_api_gateway_method.product
  rest_api_id = aws_api_gateway_rest_api.restAPIs.id
  resource_id = aws_api_gateway_resource.product.id
  http_method = each.value.http_method
  status_code = local.product_status_code

  response_templates = {
    "application/json" = ""
  }
  depends_on = [
    aws_api_gateway_method.product,
    aws_api_gateway_integration.product
  ]
}

#Health API
resource "aws_api_gateway_resource" "health-api" {
  parent_id   = aws_api_gateway_rest_api.restAPIs.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.restAPIs.id
  path_part   = "health"
}

resource "aws_api_gateway_method" "gethealth" {
  rest_api_id   = aws_api_gateway_rest_api.restAPIs.id
  resource_id   = aws_api_gateway_resource.health-api.id
  http_method   = "GET"
  authorization = "NONE"
  #api_key_required = true
}

resource "aws_api_gateway_integration" "gethealth" {
  rest_api_id             = aws_api_gateway_rest_api.restAPIs.id
  resource_id             = aws_api_gateway_resource.health-api.id
  http_method             = aws_api_gateway_method.gethealth.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
  request_templates = {
    "application/json" = ""
  }
  depends_on = [
    aws_api_gateway_resource.health-api,
    aws_api_gateway_method.gethealth
  ]
}


#response to return when the API is sucessful. Need to map to all other APIs
resource "aws_api_gateway_method_response" "health-api-response" {
  rest_api_id = aws_api_gateway_rest_api.restAPIs.id
  resource_id = aws_api_gateway_resource.health-api.id
  http_method = aws_api_gateway_method.gethealth.http_method
  status_code = local.product_status_code

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "intResponse" {
  rest_api_id = aws_api_gateway_rest_api.restAPIs.id
  resource_id = aws_api_gateway_resource.health-api.id
  http_method = aws_api_gateway_method.gethealth.http_method
  status_code = local.product_status_code

  response_templates = {
    "application/json" = ""
  }
  depends_on = [
    aws_api_gateway_method.gethealth,
    aws_api_gateway_integration.gethealth
  ]
}

#Products API
resource "aws_api_gateway_resource" "products-api" {
  parent_id   = aws_api_gateway_rest_api.restAPIs.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.restAPIs.id
  path_part   = "products"
}

resource "aws_api_gateway_method" "get-products" {
  rest_api_id   = aws_api_gateway_rest_api.restAPIs.id
  resource_id   = aws_api_gateway_resource.products-api.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration-get-products" {
  rest_api_id             = aws_api_gateway_rest_api.restAPIs.id
  resource_id             = aws_api_gateway_resource.products-api.id
  http_method             = aws_api_gateway_method.get-products.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
  request_templates = {
    "application/json" = ""
  }
  depends_on = [
    aws_api_gateway_resource.products-api,
    aws_api_gateway_method.get-products
  ]
}

resource "aws_api_gateway_method_response" "products-api-response" {
  rest_api_id = aws_api_gateway_rest_api.restAPIs.id
  resource_id = aws_api_gateway_resource.products-api.id
  http_method = aws_api_gateway_method.get-products.http_method
  status_code = local.product_status_code

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "products-response" {
  rest_api_id = aws_api_gateway_rest_api.restAPIs.id
  resource_id = aws_api_gateway_resource.products-api.id
  http_method = aws_api_gateway_method.get-products.http_method
  status_code = local.product_status_code
  response_templates = {
    "application/json" = ""
  }
  depends_on = [
      aws_api_gateway_method.get-products,
      aws_api_gateway_integration.integration-get-products
  ]
}


resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.restAPIs.id

  depends_on = [
    aws_api_gateway_integration.gethealth,
    aws_api_gateway_integration.product,
    aws_api_gateway_method.gethealth,
    aws_api_gateway_method.product,
    aws_api_gateway_method.get-products,
    aws_api_gateway_integration.integration-get-products
  ]
}

#Deployment stage of your API. When hitting the Invoke URL you will add /stage
resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.restAPIs.id
  stage_name    = var.stage-name
  description   = "2nd api test"
  tags = {
    "IaC"         = "true"
    "Environment" = var.envTag
  }
}

#IAM role for Lambda to access CloudWatch logs & DynamoDB
resource "aws_iam_role" "lambda-access-dynamodb" {
  name        = "lambda-dynamodb-3"
  description = "Allows Lambda functions to call AWS services on your behalf. Access to CloudWatch logs for troubleshooting and dynamodb for backend db."
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}


resource "aws_iam_role_policy" "access-policy" {
  name   = "lambda-access-dynmaodb-policy3"
  role   = aws_iam_role.lambda-access-dynamodb.id
  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchGetItem",
                "dynamodb:GetItem",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWriteItem",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "*"
      }
    ]
  }
  EOF
}


# Lambda
resource "aws_lambda_permission" "apigw_lambda-get-health" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
}

data "archive_file" "zip_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/lambda/lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name = "lambda_function3"
  filename      = "${path.module}/lambda/lambda.zip"
  role          = aws_iam_role.lambda-access-dynamodb.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
}

#Enable CW logging for Lambda
resource "aws_cloudwatch_log_group" "lambda-logs" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 30
}

#added API GW logging
resource "aws_api_gateway_method_settings" "api-logs" {
  rest_api_id = aws_api_gateway_rest_api.restAPIs.id
  stage_name  = aws_api_gateway_stage.example.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}


