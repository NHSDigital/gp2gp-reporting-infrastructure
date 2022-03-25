data "aws_ssm_parameter" "gocd_vpc_id" {
  name = var.gocd_vpc_id_param_name
}

data "aws_ssm_parameter" "common_account_id" {
  name = var.common_account_id_param_name
}

resource "aws_vpc_peering_connection" "private_to_gocd" {
  vpc_id        = aws_vpc.vpc.id
  peer_vpc_id   = data.aws_ssm_parameter.gocd_vpc_id.value
  peer_owner_id = data.aws_ssm_parameter.common_account_id.value
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