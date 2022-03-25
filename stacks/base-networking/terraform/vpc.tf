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
  log_destination      = aws_s3_bucket.flow_log.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc.id
}

resource "aws_s3_bucket" "flow_log" {
  bucket = "${var.environment}-data-pipeline-vpc-flow-logs"
}