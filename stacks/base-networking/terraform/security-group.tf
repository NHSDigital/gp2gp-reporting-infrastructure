resource "aws_security_group" "outbound_only" {
  name   = "${var.environment}-outbound-only"
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-data-pipeline-outbound-only"
      ApplicationRole = "AwsSecurityGroup"
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
