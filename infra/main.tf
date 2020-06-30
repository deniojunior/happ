locals {
  resource      = "${var.app}-${var.namespace}-${var.env}"
  app_subdomain = var.env == "prod" ? "${var.app}" : "${var.app}-${var.env}"
  tags = {
    Application = var.app
    Environment = var.env
  }
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
  force_destroy                      = true
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

  tags = merge(local.tags, { Name = "${local.resource}-frontend_bucket" })

  attach_policy = true
  policy        = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPublicReadAccess",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::${local.resource}-frontend/*"
      ]
    }
  ]
}
POLICY
}

module "ecr" {
  source          = "git::https://github.com/cloudposse/terraform-aws-ecr.git?ref=master"
  name            = local.resource
  max_image_count = 5
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> v2.0"

  domain_name = var.aws_route53_zone
  zone_id     = data.aws_route53_zone.selected.id

  subject_alternative_names = [
    "*.${var.aws_route53_zone}"
  ]

  tags = merge(local.tags, { Name = "${local.resource}-certificate" })
}

module "cloufront_multiorigin" {
  source = "./modules/cloudfront_multiorigin"

  lamba_edge_payload_filename = "./modules/cloudfront_multiorigin/resources/lambda_edge_payload.zip"
  lamba_edge_handler          = "lambda_edge_function.handler"
  
  bucket_regional_domain_name = module.s3_bucket.this_s3_bucket_bucket_regional_domain_name
  s3_bucket_id                = module.s3_bucket.this_s3_bucket_id
  app_subdomain               = local.app_subdomain
  acm_certificate_arn         = module.acm.this_acm_certificate_arn
  route53_zone                = var.aws_route53_zone
  route53_zone_id             = data.aws_route53_zone.selected.id

  resource = local.resource
  tags     = local.tags
}
