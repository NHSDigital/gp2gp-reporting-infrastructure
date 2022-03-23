data "aws_ssm_parameter" "data_pipeline_private_subnet_id" {
  name = var.data_pipeline_private_subnet_id_param_name
}

data "aws_ssm_parameter" "outbound_only_security_group_id" {
  name = var.data_pipeline_outbound_only_security_group_id_param_name
}

resource "aws_lambda_function" "gocd_trigger" {
  filename      = var.gocd_trigger_lambda_zip
  function_name = "${var.environment}-dashboard-pipeline-gocd-trigger"
  role          = aws_iam_role.gocd_trigger.arn
  handler       = "main.lambda_handler"
  tags          = local.common_tags

  source_code_hash = filebase64sha256(var.gocd_trigger_lambda_zip)

  runtime = "python3.9"

  environment {
    variables = {
      GOCD_API_TOKEN_PARAM_NAME = var.gocd_trigger_api_token_ssm_param_name
      GOCD_API_URL_PARAM_NAME   = var.gocd_trigger_api_url_ssm_param_name
    }
  }

  vpc_config {
    subnet_ids         = [data.aws_ssm_parameter.data_pipeline_private_subnet_id.value]
    security_group_ids = [data.aws_ssm_parameter.outbound_only_security_group_id.value]
  }
}

resource "aws_cloudwatch_log_group" "gocd_trigger" {
  name = "/aws/lambda/${var.environment}-dashboard-pipeline-gocd-trigger"
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-dashboard-pipeline-gocd-trigger"
    }
  )
  retention_in_days = 14
}

