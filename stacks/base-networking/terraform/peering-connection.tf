data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "gocd_vpc_id" {
  name = var.gocd_vpc_id_param_name
}

resource "aws_vpc_peering_connection" "private_to_gocd" {
  peer_vpc_id   = data.aws_ssm_parameter.gocd_vpc_id.value
  vpc_id        = aws_vpc.vpc.id
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_region   = data.aws_region.current.name
  auto_accept   = false

  tags = merge(
    local.common_tags,
    {
      Name = "Data pipeline VPC to GoCD VPC Peering connection",
      Side = "Requester"
    }
  )
}