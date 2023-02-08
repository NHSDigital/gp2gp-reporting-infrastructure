resource "aws_ssm_parameter" "private_subnet_id" {
  name  = "/registrations/${var.environment}/data-pipeline/base-networking/private-subnet-id"
  type  = "String"
  value = aws_subnet.private.id
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-private-subnet-id"
      ApplicationRole = "AwsSsmParameter"
    }
  )

}

resource "aws_ssm_parameter" "outbound_only_security_group_id" {
  name  = "/registrations/${var.environment}/data-pipeline/base-networking/outbound-only-security-group-id"
  type  = "String"
  value = aws_security_group.outbound_only.id
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-outbound-only-security-group-id"
      ApplicationRole = "AwsSsmParameter"
    }
  )
}

