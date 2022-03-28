resource "aws_ssm_parameter" "private_subnet_id" {
  name  = "/registrations/${var.environment}/data-pipeline/base-networking/private-subnet-id"
  type  = "String"
  value = aws_subnet.private.id
  tags  = local.common_tags
}

resource "aws_ssm_parameter" "outbound_only_security_group_id" {
  name  = "/registrations/${var.environment}/data-pipeline/base-networking/outbound-only-security-group-id"
  type  = "String"
  value = aws_security_group.outbound_only.id
  tags  = local.common_tags
}

resource "aws_ssm_parameter" "gocd_vpc_outbound_only_security_group_id" {
  name  = "/registrations/${var.environment}/data-pipeline/base-networking/gocd-vpc-outbound-only-security-group-id"
  type  = "String"
  value = aws_security_group.gocd_vpc_outbound_only.id
  tags  = local.common_tags
}
