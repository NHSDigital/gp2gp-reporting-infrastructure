resource "aws_api_gateway_rest_api" "degrades_api" {
  name        = "degrades_api"
  description = "API for Degrades work"
}

resource "aws_api_gateway_deployment" "degrades_api_deploy" {
  rest_api_id = aws_api_gateway_rest_api.degrades_api.id
}

resource "aws_api_gateway_stage" "degrades" {
  deployment_id = aws_api_gateway_deployment.degrades_api_deploy.id
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.degrades_api.id
}


resource "aws_api_gateway_resource" "degrades" {
  parent_id   = aws_api_gateway_rest_api.degrades_api.root_resource_id
  path_part   = "degrades"
  rest_api_id = aws_api_gateway_rest_api.degrades_api.id
}

resource "aws_api_gateway_method" "degrades_get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.degrades.id
  rest_api_id   = aws_api_gateway_rest_api.degrades_api.id
}

resource "aws_api_gateway_integration" "degrades_get" {
  http_method = aws_api_gateway_method.degrades_get.http_method
  resource_id = aws_api_gateway_resource.degrades.id
  rest_api_id = aws_api_gateway_rest_api.degrades_api.id
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.degrades_lambda.invoke_arn
}