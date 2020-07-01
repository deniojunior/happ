locals {
  resource = "${var.app}-${var.namespace}-${var.env}"
  app_name = var.env == "prod" ? "${var.app}" : "${var.app}-${var.env}"
  tags = {
    Application = var.app
    Environment = var.env
  }
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  origin {
    domain_name = module.s3_bucket.this_s3_bucket_bucket_regional_domain_name
    origin_id   = module.s3_bucket.this_s3_bucket_id
  }

  origin {
    domain_name = var.alb_dns
    origin_id = "${var.alb_dns}-id"
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = ["${local.app_name}.${var.aws_route53_zone}"]

  default_cache_behavior {
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

  ordered_cache_behavior {
    path_pattern     = "/frontend"
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

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.lambda_edge.qualified_arn
      include_body = false
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/backend"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    
    target_origin_id = "${var.alb_dns}-id"

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

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.lambda_edge.qualified_arn
      include_body = false
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge(local.tags, { Name = "${local.resource}-cdn" })

  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = "sni-only"
  }

  depends_on = [
    aws_lambda_function.lambda_edge
  ]

}

resource "aws_route53_record" "cname" {
  zone_id = data.aws_route53_zone.selected.id
  name    = local.app_name
  type    = "CNAME"
  ttl     = "5"

  records = [aws_cloudfront_distribution.cf_distribution.domain_name]

  depends_on = [
    aws_cloudfront_distribution.cf_distribution
  ]
}

resource "aws_lambda_function" "lambda_edge" {
  filename      = "./resources/lambda_edge_payload.zip"
  function_name = "${local.resource}-lambda-edge"
  role          = aws_iam_role.lambda_edge_role.arn
  handler       = "lambda_edge_function.handler"
  runtime       = "nodejs12.x"
  publish       = true

  tags             = merge(local.tags, { Name = "${local.resource}-lambda-edge" })
  source_code_hash = "filebase64sha256(./resources/lambda_edge_payload.zip)"
}

resource "aws_iam_role" "lambda_edge_role" {
  name = "${local.resource}-lambda-edge-iam-role"

  tags = merge(local.tags, { Name = "${local.resource}-lambda-role" })

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_edge_policy" {
  name = "${local.resource}-lambda-edge-iam-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
  ]
} 
EOF
}

resource "aws_iam_policy_attachment" "lambda_edge_policy_attachment" {
  name       = "${local.resource}-attachment"
  roles      = [aws_iam_role.lambda_edge_role.name]
  policy_arn = aws_iam_policy.lambda_edge_policy.arn
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
