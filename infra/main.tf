locals {
  resource = "${var.app}-${var.namespace}-${var.env}"
}

module "terraform_state_backend" {
  source                             = "git::https://github.com/cloudposse/terraform-aws-tfstate-backend.git?ref=master"
  namespace                          = "${var.app}-${var.namespace}"
  name                               = "terraform"
  environment                        = var.env
  attributes                         = ["state"]
  region                             = "us-east-1"
  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend.tf"
  force_destroy                      = false
  prevent_unencrypted_uploads        = false
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = "${local.resource}-frontend"
  acl           = "private"
  force_destroy = true

  website = {
    index_document = "index.html"
  }

  tags = {
    Application = var.app
    Environment = var.env
    Name        = "${local.resource}-frontend"
  }

  policy = file("./resources/frontend_bucket_policy.json")
}

data "aws_iam_role" "ecr" {
  name = "ecr"
}

module "ecr" {
  source                 = "git::https://github.com/cloudposse/terraform-aws-ecr.git?ref=master"
  name                   = local.resource
  principals_full_access = [data.aws_iam_role.ecr.arn]
  max_image_count        = 5
}
