provider "aws" {
  version = "~> 2.0"
  region  = var.aws_region
}

data aws_route53_zone "selected" {
  name = var.aws_route53_zone
}
