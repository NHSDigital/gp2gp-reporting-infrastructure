resource "aws_ssm_parameter" "gp2gp_dashboard_alert_lambda_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/gp2gp-dashboard/gp2gp-dashboard-alert-lambda-arn"
  type  = "String"
  value = aws_lambda_function.gp2gp_dashboard_alert_lambda.arn
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-gp2gp-dashboard-alert-lambda-arn"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}