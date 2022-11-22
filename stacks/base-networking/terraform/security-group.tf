data "aws_ssm_parameter" "gocd_vpc_id" {
  name = var.gocd_vpc_id_param_name
}

resource "aws_security_group" "outbound_only" {
  name   = "${var.environment}-outbound-only"
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-data-pipeline-outbound-only"
    }
  )
}

resource "aws_security_group_rule" "outbound_only" {
  type              = "egress"
  security_group_id = aws_security_group.outbound_only.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Unrestricted egress"
}

resource "aws_security_group" "gocd_vpc_outbound_only" {
  name   = "${var.environment}-gocd-vpc-outbound-only"
  vpc_id = data.aws_ssm_parameter.gocd_vpc_id.value

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-gocd-vpc-outbound-only"
    }
  )
}

resource "aws_security_group_rule" "gocd_vpc_outbound_only" {
  type              = "egress"
  security_group_id = aws_security_group.gocd_vpc_outbound_only.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Unrestricted egress"
}

# TODO : delete after setup prod
resource "aws_security_group" "gocd_vpc_outbound_only_preprod_temp" {
  name   = "preprod-gocd-vpc-outbound-only"
  vpc_id = data.aws_ssm_parameter.gocd_vpc_id.value

  tags = merge(
    local.common_tags,
    {
      Name = "preprod-gocd-vpc-outbound-only"
    }
  )
}

resource "aws_security_group_rule" "gocd_vpc_outbound_only_preprood_temp" {
  type              = "egress"
  security_group_id = aws_security_group.gocd_vpc_outbound_only_preprod_temp.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Unrestricted egress"
}