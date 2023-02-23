resource "aws_ssm_parameter" "gp2gp_dashboard_pipeline_step_function_arn" {
  name  = "/registrations/${var.environment}/data-pipeline/gp2gp-dashboard/step-function-arn"
  type  = "String"
  value = aws_sfn_state_machine.dashboard_pipeline.arn
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-gp2gp-dashboard-pipeline-step-function-arn"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}