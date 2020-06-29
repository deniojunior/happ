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

resource "aws_iam_role" "this" {
  assume_role_policy = file("./resources/iam_role.json")
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.this.arn]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${local.resource}-frontend",
    ]
  }
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

  attach_policy = true
  policy        = data.aws_iam_policy_document.bucket_policy.json
}

module "ecr" {
  source                 = "git::https://github.com/cloudposse/terraform-aws-ecr.git?ref=master"
  name                   = local.resource
  max_image_count        = 5
}
