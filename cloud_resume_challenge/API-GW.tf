resource "aws_api_gateway_rest_api" "API" {
  name        = "lambda-api-terraform"
  description = "lambda-api-terraform"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# GATEWAY FLOW

resource "aws_api_gateway_method" "Method" {
  rest_api_id   = aws_api_gateway_rest_api.API.id
  resource_id   = aws_api_gateway_rest_api.API.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.API.id
  resource_id = aws_api_gateway_rest_api.API.root_resource_id
  http_method = aws_api_gateway_method.Method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type"                = true # ✅ Must be boolean (true or false)
    "method.response.header.Access-Control-Allow-Origin" = true
    # "method.response.header.Access-Control-Allow-Methods" = true
    # "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration" "Integration" {
  rest_api_id             = aws_api_gateway_rest_api.API.id
  resource_id             = aws_api_gateway_rest_api.API.root_resource_id
  http_method             = aws_api_gateway_method.Method.http_method
  integration_http_method = "POST" #ALWAYS USE POST
  type                    = "AWS"
  uri                     = aws_lambda_function.lambda-function.invoke_arn
}

resource "aws_api_gateway_integration_response" "Integration-Response" {
  rest_api_id = aws_api_gateway_rest_api.API.id
  resource_id = aws_api_gateway_rest_api.API.root_resource_id
  http_method = aws_api_gateway_method.Method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  response_templates = {
    "application/json" = "" # Optional, can transform responses if needed
  }

  response_parameters = {
    "method.response.header.Content-Type"                = "'application/json'" # Optional, ensures correct content type
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    # "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    # "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }

  depends_on = [
    aws_api_gateway_integration.Integration
  ]
}

# END GATEWAY FLOW


#  DEPLOYMENT

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.API.id

  depends_on = [
    aws_api_gateway_integration.Integration # ✅ Ensures the integration is created first
  ]

}

resource "aws_api_gateway_stage" "test" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.API.id
  stage_name    = "test"
  description   = "Test stage for API"

  depends_on = [
    aws_api_gateway_deployment.example # ✅ Ensures the integration is created first
  ]

}

# ADDING PERMISSIONS

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "apigw-lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.API.id}/*/${aws_api_gateway_method.Method.http_method}/"
}


# # USED TO CREATE A PATH IN THE API GATEWAY 
# # Set the Resource as BASE PATH for now
# resource "aws_api_gateway_resource" "Resource" {
#   rest_api_id = aws_api_gateway_rest_api.API.id
#   parent_id   = aws_api_gateway_rest_api.API.root_resource_id
#   path_part   = "" # Empty path for base path ("/")
# }