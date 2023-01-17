provider "aws" {
  region = var.region
  version = "~> 3.74"
}

provider "aws" {
  alias  = "cf_certificate_only_region"
  region = "us-east-1"
  version = "~> 3.74"
}