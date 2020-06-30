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

  tags = {
    Application = var.app
    Environment = var.env
    Name        = "${local.resource}-frontend"
  }

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

  domain_name  = "devsforlife.org"
  zone_id = data.aws_route53_zone.selected.id

  subject_alternative_names = [
    "*.devsforlife.org"
  ]

  tags = {
    Application = var.app
    Environment = var.env
    Name        = "${local.resource}-frontend"
  }
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  origin {
    domain_name = module.s3_bucket.this_s3_bucket_bucket_regional_domain_name
    origin_id   = module.s3_bucket.this_s3_bucket_id
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = ["happ.devsforlife.org"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = module.s3_bucket.this_s3_bucket_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    path_pattern     = "/frontend/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = module.s3_bucket.this_s3_bucket_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Application = var.app
    Environment = var.env
    Name        = "${local.resource}-cdn"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn = module.acm.this_acm_certificate_arn
    ssl_support_method = "sni-only"
  }
  
  depends_on = [
    module.acm.this_acm_certificate_arn
  ]
}

resource "aws_route53_record" "cname" {
  zone_id = data.aws_route53_zone.selected.id
  name    = var.env == "prod" ? "happ" : "happ-${var.env}"
  type    = "CNAME"
  ttl     = "5"

  records = [aws_cloudfront_distribution.cf_distribution.domain_name]

  depends_on = [
    aws_cloudfront_distribution.cf_distribution
  ]
}
