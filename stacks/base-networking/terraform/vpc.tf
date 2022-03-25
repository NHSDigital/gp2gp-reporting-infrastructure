resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-data-pipeline-vpc"
    }
  )
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-data-pipeline"
    }
  )
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_names = data.aws_availability_zones.available.names
}

resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn         = aws_iam_role.vpc_flow_log.arn
  log_destination_type = aws_cloudwatch_log_group.vpc_flow_log.arn
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc.id
}

resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name              = "/vpc/${var.environment}-data-pipeline-vpc-flow-log"
  retention_in_days = var.retention_period_in_days
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-data-pipeline"
    }
  )
}
