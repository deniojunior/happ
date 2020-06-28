locals {
  resource = "${var.app}.${var.env}"
}

module "terraform_state_backend" {
  source                             = "git::https://github.com/cloudposse/terraform-aws-tfstate-backend.git?ref=master"
  namespace                          = "happ"
  delimiter                          = "."
  stage                              = var.env
  name                               = "terraform"
  attributes                         = ["state"]
  region                             = "us-east-1"
  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend.tf"
  force_destroy                      = false
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = "${local.resource}.frontend"
  acl           = "private"
  force_destroy = true

  tags = {
    Application = var.app
    Environment = var.env
    Name        = "${local.resource}.frontend"
  }
}
